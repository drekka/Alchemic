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
#import <Alchemic/ALCDependency.h>
#import <Alchemic/ALCException.h>
#import <Alchemic/ALCFlagMacros.h>
#import <Alchemic/ALCInjector.h>
#import <Alchemic/ALCInstantiation.h>
#import <Alchemic/ALCMacros.h>
#import <Alchemic/ALCInternalMacros.h>
#import <Alchemic/ALCRuntime.h>
#import <Alchemic/ALCVariableDependency.h>
#import <Alchemic/NSArray+Alchemic.h>
#import <Alchemic/NSObject+Alchemic.h>


@implementation ALCClassObjectFactory {

    BOOL _resolved;
    BOOL _checkingReadyStatus;

    NSMutableArray<id<ALCDependency>> *_dependencies;

    // Populated so we can reinject values if dependencies update.
    // Using a weak based hashtable so we don't have to maintain it.
    NSHashTable *_injectedObjectHistory;

}

@synthesize initializer = _initializer;

#pragma mark - Life cycle

-(instancetype) initWithClass:(Class) objectClass {
    self = [super initWithClass:objectClass];
    if (self) {
        _dependencies = [[NSMutableArray alloc] init];
        _injectedObjectHistory = [[NSHashTable alloc] initWithOptions:NSHashTableWeakMemory capacity:0];
    }
    return self;
}

-(void)configureWithOption:(id)option model:(id<ALCModel>) model {
    if (_initializer && [option isKindOfClass:[ALCIsReference class]]) {
        throwException(IllegalArgument, @"Factories with initializers cannot be set to reference external objects");
    } else {
        [super configureWithOption:option model:model];
    }
}

-(void) registerVariableDependency:(Ivar) variable
                          injector:(id<ALCInjector>) injector
                          withName:(NSString *) variableName {
    ALCVariableDependency *ref = [ALCVariableDependency variableDependencyWithInjector:injector
                                                                              intoIvar:variable
                                                                                  name:variableName];
    [_dependencies addObject:ref];
}

-(void)resolveWithStack:(NSMutableArray<id<ALCResolvable>> *)resolvingStack model:(id<ALCModel>) model {

    STLog(self.objectClass, @"Resolving class factory %@", NSStringFromClass(self.objectClass));

    AcWeakSelf;
    [self resolveWithResolvingStack:resolvingStack
                       resolvedFlag:&_resolved
                              block:^{

                                  AcStrongSelf;
                                  [strongSelf->_initializer resolveWithStack:resolvingStack model:model];

                                  STLog(strongSelf.objectClass, @"Resolving %i injections into a %@", strongSelf->_dependencies.count, NSStringFromClass(strongSelf.objectClass));
                                  for (ALCVariableDependency *ref in strongSelf->_dependencies) {
                                      [resolvingStack addObject:ref];
                                      [ref.injector resolveWithStack:resolvingStack model:model];
                                      [resolvingStack removeLastObject];
                                  }
                              }];

    // Check for the need to watch notifications.
    for (ALCVariableDependency *dependency in _dependencies) {
        if (dependency.transient) {
            [self setDependencyUpdateObserverWithBlock:^(NSNotification *notification) {
                AcStrongSelf;
                id sourceObjectFactory = notification.object;
                for (ALCVariableDependency *variableDependency in strongSelf->_dependencies) {
                    if (variableDependency.transient && [variableDependency referencesObjectFactory:sourceObjectFactory]) {
                        for (id object in strongSelf->_injectedObjectHistory) {
                            STLog(strongSelf.objectClass, @"Updating dependency value %@", variableDependency);
                            [strongSelf injectObject:object dependency:variableDependency];
                        }
                    }
                }
            }];
            break;
        }
    }
}

-(BOOL) isReady {
    if (super.isReady && (!_initializer || _initializer.isReady)) {
        return [_dependencies dependenciesReadyWithCurrentlyCheckingFlag:&_checkingReadyStatus];
    }
    return NO;
}

-(id) createObject {
    if (_initializer) {
        return _initializer.createObject;
    }
    STLog(self.objectClass, @"Instantiating a %@ using init", NSStringFromClass(self.objectClass));
    return [[self.objectClass alloc] init];
}

-(ALCBlockWithObject) objectCompletion {
    AcWeakSelf;
    return ^(ALCBlockWithObjectArgs){
        AcStrongSelf;
        [strongSelf injectDependencies:object];
    };
}

#pragma mark - Tasks

-(void) injectDependencies:(id) object {

    STLog(self.objectClass, @"Injecting dependencies into a %@", NSStringFromClass(self.objectClass));

    // Perform injections.
    for (ALCVariableDependency *dep in _dependencies) {
        [self injectObject:object dependency:dep];
    }

    // Store a weak reference.
    [_injectedObjectHistory addObject:object];

    // Notify of injection completion.
    if ([object respondsToSelector:@selector(alchemicDidInjectDependencies)]) {
        STLog(self, @"Telling %@ it's injections have finished", object);
        [(id<AlchemicAware>)self alchemicDidInjectDependencies];
    }
}

-(void) injectObject:(id) object dependency:(ALCVariableDependency *) dependency {
    [ALCRuntime executeSimpleBlock:[dependency injectObject:object]];
    if ([object respondsToSelector:@selector(alchemicDidInjectVariable:)]) {
        [(id<AlchemicAware>)self alchemicDidInjectVariable:dependency.name];
    }
}

#pragma mark - Descriptions

-(NSString *) description {
    return str(@"%@ class %@", super.description, self.defaultModelKey);
}

-(NSString *)resolvingDescription {
    return str(@"Class %@", NSStringFromClass(self.objectClass));
}

@end
