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

-(id) instantiateObject {
    if (_initializer) {
        return _initializer.object;
    }
    STLog(self.objectClass, @"Instantiating a %@ using init", NSStringFromClass(self.objectClass));
    return [[self.objectClass alloc] init];
}

-(void) setObject:(id) object {

    super.object = object;

    // We need to somehow allow other code to execute here or some circular references will not work.
    // Mainly, obj1.init(arg) --> obj2.prop --> obj1
    // Because obj2.prop is needed before obj1 is created.
    dispatch_async(dispatch_get_main_queue(), ^{

        [self injectDependenciesIntoObject:object];

        if ([object respondsToSelector:@selector(alchemicDidInjectDependencies)]) {
            [object alchemicDidInjectDependencies];
        }

        [[NSNotificationCenter defaultCenter] postNotificationName:AlchemicDidCreateObject
                                                            object:self
                                                          userInfo:@{AlchemicDidCreateObjectUserInfoObject: object}];
    });
}

-(void) injectDependenciesIntoObject:(id) value {
    for (ALCDependencyRef *depRef in _dependencies) {
        STLog(self.objectClass, @"Injecting %@.%@", NSStringFromClass(self.objectClass), depRef.name);
        [depRef.dependency setObject:value variable:depRef.ivar];
    }
}

-(NSArray<id<ALCDependency>> *) referencedDependencies {
    NSMutableArray *deps = [NSMutableArray arrayWithCapacity:_dependencies.count];
    for (ALCDependencyRef *ref in _dependencies) {
        [deps addObject:ref.dependency];
    }
    return deps;
}


@end
