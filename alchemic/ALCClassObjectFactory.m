//
//  ALCClassObjectFactory.m
//  Alchemic
//
//  Created by Derek Clarkson on 12/02/2016.
//  Copyright © 2016 Derek Clarkson. All rights reserved.
//

@import StoryTeller;

#import "ALCClassObjectFactory.h"

#import "ALCClassObjectFactoryInitializer.h"
#import "ALCMacros.h"
#import "ALCInternalMacros.h"
#import "ALCVariableDependency.h"
#import "NSArray+Alchemic.h"
#import "NSObject+Alchemic.h"
#import "AlchemicAware.h"
#import "ALCType.h"
#import "ALCRuntime.h"

@implementation ALCClassObjectFactory {

    BOOL _resolved;
    BOOL _checkingReadyStatus;

    NSMutableArray<id<ALCDependency>> *_dependencies;

    // Populated if there are transient dependencies so we can reinject values if they update.
    // Using a weak based hashtable so we don't have to maintain it.
    NSHashTable *_injectedObjectHistory;

    // The notification observer listening to dependency updates. Currently only used by transient dependencies.
    id _dependencyChangedObserver;

}

@synthesize initializer = _initializer;

#pragma mark - Life cycle

-(instancetype) initWithType:(ALCType *)type {
    self = [super initWithType:type];
    if (self) {
        _dependencies = [[NSMutableArray alloc] init];
    }
    return self;
}

-(ALCVariableDependency *) registerVariableDependency:(Ivar) variable
                                                 type:(ALCType *) type
                                          valueSource:(id<ALCValueSource>) valueSource
                                             withName:(NSString *) variableName {
    ALCVariableDependency *dependency = [ALCVariableDependency variableDependencyWithType:type
                                                                              valueSource:valueSource
                                                                                 intoIvar:variable
                                                                                 withName:variableName];
    [_dependencies addObject:dependency];
    return dependency;
}

-(void)resolveWithStack:(NSMutableArray<id<ALCResolvable>> *)resolvingStack model:(id<ALCModel>) model {

    STStartScope(self.type);
    STLog(self.type, @"Resolving class factory %@", NSStringFromClass(self.type.objcClass));

    // Validate we are not trying to specify an intializer for a reference factory.
    if (_initializer && self.factoryType == ALCFactoryTypeReference) {
        throwException(AlchemicIllegalArgumentException, @"Reference factories cannot have initializers");
    }

    AcWeakSelf;
    [self resolveWithStack:resolvingStack
              resolvedFlag:&_resolved
                     block:^{
                         AcStrongSelf;
                         [strongSelf->_initializer resolveWithStack:resolvingStack model:model];

                         STLog(strongSelf.type, @"Resolving %lu variable injections in a %@", (unsigned long) strongSelf->_dependencies.count, NSStringFromClass(strongSelf.type.objcClass));
                         [strongSelf->_dependencies resolveWithStack:resolvingStack model:model];
                     }];

    // Figure out if we need to watch for transient factory changes.
    for (ALCVariableDependency *dependency in _dependencies) {
        if (dependency.referencesTransients) {
            STLog(self, @"%@ is references a transient, configuring factory to watch for changes", [ALCRuntime forClass:self.type.objcClass propertyDescription:dependency.name]);
            // Any dependency which refers to transients must be nillable.
            [dependency configureWithOptions:@[AcNillable]];
            [self setUpTransientWatch];
        }
    }
}

-(void) setUpTransientWatch {

    // We need to track all objects we have injected which are still active so we can re-inject them on a transient change.
    _injectedObjectHistory = [[NSHashTable alloc] initWithOptions:NSHashTableWeakMemory capacity:0];

    AcWeakSelf;
    void (^dependenciesChanged)(NSNotification *notificaton) = ^(NSNotification *notification) {

        AcStrongSelf;
        id sourceObjectFactory = notification.object;

        if (strongSelf->_injectedObjectHistory.count > 0) {

            STLog(self, @"%@ checking transient changed notification", NSStringFromClass(self.type.objcClass));

            // Loop through all dependencies and check to see if they are watching the factory that has changed it's value.
            for (ALCVariableDependency *variableDependency in strongSelf->_dependencies) {
                if ([variableDependency referencesObjectFactory:sourceObjectFactory]) {
                    STLog(self, @"Found dependency which needs updating, injecting %lu objects", (unsigned long) strongSelf->_injectedObjectHistory.count);
                    for (id object in strongSelf->_injectedObjectHistory) {
                        [strongSelf injectObject:object dependency:variableDependency];
                    }
                }
            }
        }
    };

    self->_dependencyChangedObserver = [[NSNotificationCenter defaultCenter] addObserverForName:AlchemicDidStoreObject
                                                                                         object:nil
                                                                                          queue:nil
                                                                                     usingBlock:dependenciesChanged];
}

-(BOOL) isReady {
    if (super.isReady && (!_initializer || _initializer.isReady)) {
        return [_dependencies dependenciesReadyWithCheckingFlag:&_checkingReadyStatus];
    }
    return NO;
}

-(id) createObject {
    if (_initializer) {
        return _initializer.createObject;
    }
    STLog(self.type, @"Instantiating a %@ using init", NSStringFromClass(self.type.objcClass));
    return [[self.type.objcClass alloc] init];
}

-(ALCBlockWithObject) objectCompletion {
    AcWeakSelf;
    return ^(ALCBlockWithObjectArgs){
        STLog(self, @"Completing object variable injections");
        AcStrongSelf;
        [strongSelf injectDependencies:object];
    };
}

-(void) unload {
    if (_dependencyChangedObserver) {
        [[NSNotificationCenter defaultCenter] removeObserver:_dependencyChangedObserver];
    }
}

#pragma mark - Tasks

-(void) injectDependencies:(id) object {

    // Perform injections.
    for (ALCVariableDependency *dep in _dependencies) {
        [self injectObject:object dependency:dep];
    }

    // Store a weak reference.
    if (_injectedObjectHistory) {
        STLog(self, @"Storing object in injection history");
        [_injectedObjectHistory addObject:object];
    }

    // Notify of injection completion.
    if ([object respondsToSelector:@selector(alchemicDidInjectDependencies)]) {
        STLog(self, @"Telling %@ it's injections are done", object);
        [(id<AlchemicAware>) object alchemicDidInjectDependencies];
    }
}

-(void) injectObject:(id) object dependency:(ALCVariableDependency *) dependency {

    STLog(self, @"Injecting variable %@", dependency.name);

    [dependency injectObject:object];

    if ([object respondsToSelector:@selector(alchemicDidInjectVariable:)]) {
        [(id<AlchemicAware>) object alchemicDidInjectVariable:dependency.name];
    }
}

#pragma mark - Descriptions

-(NSString *) description {
    return str(@"%@ class %@", super.description, self.defaultModelName);
}

-(NSString *)resolvingDescription {
    return str(@"Class %@", NSStringFromClass(self.type.objcClass));
}

@end
