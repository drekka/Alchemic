//
//  ALCClassObjectFactory.m
//  Alchemic
//
//  Created by Derek Clarkson on 12/02/2016.
//  Copyright © 2016 Derek Clarkson. All rights reserved.
//

@import StoryTeller;

#import <Alchemic/ALCClassObjectFactory.h>

#import <Alchemic/ALCClassObjectFactoryInitializer.h>
#import <Alchemic/ALCMacros.h>
#import <Alchemic/ALCInternalMacros.h>
#import <Alchemic/ALCVariableDependency.h>
#import <Alchemic/NSArray+Alchemic.h>
#import <Alchemic/NSObject+Alchemic.h>
#import <Alchemic/AlchemicAware.h>
#import <Alchemic/ALCType.h>

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
                         
                         STLog(strongSelf.type, @"Resolving %lu injections into a %@", (unsigned long) strongSelf->_dependencies.count, NSStringFromClass(strongSelf.type.objcClass));
                         [strongSelf->_dependencies resolveWithStack:resolvingStack model:model];
                     }];
    
    // Find the first transient dependency and setup watching notifications.
    for (ALCVariableDependency *dependency in _dependencies) {
        if (dependency.referencesTransients) {
            [self setUpTransientWatch];
            break;
        }
    }
}

-(void) setUpTransientWatch {
    // If there is no history storage then add it.
    if (!_injectedObjectHistory) {
        _injectedObjectHistory = [[NSHashTable alloc] initWithOptions:NSHashTableWeakMemory capacity:0];
    }
    
    // Set up the dependency to watch the factories it resolves.
    AcWeakSelf;
    void (^dependenciesChanged)(NSNotification *notificaton) = ^(NSNotification *notification) {
        
        AcStrongSelf;
        id sourceObjectFactory = notification.object;
        
        // Loop through all dependencies and check to see if they are watching the factory that had it's value changed.
        for (ALCVariableDependency *variableDependency in strongSelf->_dependencies) {
            if (variableDependency.referencesTransients
                && [variableDependency referencesObjectFactory:sourceObjectFactory]) {
                
                // Loop through all the objects this factory has injected and update the dependency in them.
                for (id object in strongSelf->_injectedObjectHistory) {
                    STLog(strongSelf.type, @"Updating dependency value %@", variableDependency);
                    [strongSelf injectObject:object dependency:variableDependency];
                }
            }
        }
    };
    
    STLog(self, @"Watching for dependency changes");
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
    
    STLog(self.type, @"Injecting dependencies into a %@", NSStringFromClass(self.type.objcClass));
    
    // Perform injections.
    for (ALCVariableDependency *dep in _dependencies) {
        [self injectObject:object dependency:dep];
    }
    
    // Store a weak reference.
    [_injectedObjectHistory addObject:object];
    
    // Notify of injection completion.
    if ([object respondsToSelector:@selector(alchemicDidInjectDependencies)]) {
        STLog(self, @"Telling %@ it's injections are done", object);
        [(id<AlchemicAware>) object alchemicDidInjectDependencies];
    }
}

-(void) injectObject:(id) object dependency:(ALCVariableDependency *) dependency {
    
    STLog(self, @"Starting injection of variable %@", dependency.name);
    
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
