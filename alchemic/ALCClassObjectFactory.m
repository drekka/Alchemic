//
//  ALCClassObjectFactory.m
//  Alchemic
//
//  Created by Derek Clarkson on 12/02/2016.
//  Copyright © 2016 Derek Clarkson. All rights reserved.
//

#import <StoryTeller/StoryTeller.h>

#import "ALCClassObjectFactory.h"
#import "ALCDependencyRef.h"
#import "ALCRuntime.h"
#import "NSObject+Alchemic.h"
#import "ALCInternalMacros.h"
#import "ALCDependency.h"
#import "ALCClassObjectFactoryInitializer.h"
#import "AlchemicAware.h"
#import "Alchemic.h"
#import "ALCFactoryResult.h"

@implementation ALCClassObjectFactory {
    NSMutableArray<ALCDependencyRef *> *_dependencies;
    BOOL _enumeratingDependencies;
}

@synthesize initializer = _initializer;

-(instancetype) initWithClass:(Class) objectClass {
    self = [super initWithClass:objectClass];
    if (self) {
        _dependencies = [[NSMutableArray alloc] init];
    }
    return self;
}

-(void) registerDependency:(id<ALCDependency>) dependency forVariable:(NSString *) variableName {
    ALCDependencyRef *ref = [[ALCDependencyRef alloc] init];
    ref.ivar = [ALCRuntime aClass:self.objectClass variableForInjectionPoint:variableName];
    ref.name = variableName;
    ref.dependency = dependency;
    [_dependencies addObject:ref];
}

-(void)resolveWithStack:(NSMutableArray<NSString *> *)resolvingStack model:(id<ALCModel>)model {

    [self resolveFactoryWithResolvingStack:resolvingStack
                             resolvingFlag:&_enumeratingDependencies
                                     block:^{
                                         if (self->_initializer) {
                                             [self->_initializer resolveWithStack:resolvingStack model:model];
                                         }
                                         for (ALCDependencyRef *ref in self->_dependencies) {
                                             NSString *name = str(@"%@.%@", self.defaultName, ref.name);
                                             // Class dependencies start a new stack.
                                             NSMutableArray *newStack = [[NSMutableArray alloc] init];
                                             [(NSObject *)ref.dependency resolveDependencyWithResolvingStack:newStack withName:name model:model];
                                         }
                                     }];
}

-(BOOL) ready {
    if (super.ready && (!_initializer || _initializer.ready)) {
        return [self dependenciesReady:[self referencedDependencies] resolvingFlag:&_enumeratingDependencies];
    }
    return NO;
}

-(ALCFactoryResult *) generateResult {

    id obj;
    ALCSimpleBlock initializerCompletion = NULL;
    if (_initializer) {
        ALCFactoryResult *initializerResult = _initializer.factoryResult;
        obj = initializerResult.object;
        initializerCompletion = initializerResult.completion;
    } else {
        STLog(self.objectClass, @"Instantiating a %@ using init", NSStringFromClass(self.objectClass));
        obj = [[self.objectClass alloc] init];
    }

    return [ALCFactoryResult resultWithObject:obj
                                   completion:^{

                                       if (initializerCompletion) {
                                           initializerCompletion();
                                       }

                                       [self injectDependenciesIntoObject:obj];

                                       if ([obj respondsToSelector:@selector(alchemicDidInjectDependencies)]) {
                                           [obj alchemicDidInjectDependencies];
                                       }

                                       [[NSNotificationCenter defaultCenter] postNotificationName:AlchemicDidCreateObject
                                                                                           object:self
                                                                                         userInfo:@{AlchemicDidCreateObjectUserInfoObject: obj}];
                                   }];
}

-(NSArray<id<ALCDependency>> *) referencedDependencies {
    NSMutableArray *deps = [NSMutableArray arrayWithCapacity:_dependencies.count];
    for (ALCDependencyRef *ref in _dependencies) {
        [deps addObject:ref.dependency];
    }
    return deps;
}

-(void) injectDependenciesIntoObject:(id) value {
    for (ALCDependencyRef *depRef in _dependencies) {
        STLog(self.objectClass, @"Injecting %@.%@", NSStringFromClass(self.objectClass), depRef.name);
        [depRef.dependency setObject:value variable:depRef.ivar];
    }
}

@end
