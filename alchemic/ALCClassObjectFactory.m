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
#import "ALCInstantiation.h"

@implementation ALCClassObjectFactory {
    NSMutableArray<ALCDependencyRef *> *_dependencies;
    BOOL _resolved;
    BOOL _checkingReadyStatus;
}

@synthesize initializer = _initializer;

-(instancetype) initWithClass:(Class) objectClass {
    self = [super initWithClass:objectClass];
    if (self) {
        _dependencies = [[NSMutableArray alloc] init];
    }
    return self;
}

-(void) registerDependency:(id<ALCDependency>) dependency forVariable:(Ivar) variable withName:(NSString *) variableName {
    ALCDependencyRef *ref = [[ALCDependencyRef alloc] init];
    ref.ivar = variable;
    ref.name = variableName;
    ref.dependency = dependency;
    [_dependencies addObject:ref];
}

-(void)resolveWithStack:(NSMutableArray<NSString *> *)resolvingStack model:(id<ALCModel>) model {
    STLog(self.objectClass, @"Resolving class factory %@", NSStringFromClass(self.objectClass));
    blockSelf;
    [self resolveFactoryWithResolvingStack:resolvingStack
                              resolvedFlag:&_resolved
                                     block:^{
                                         [strongSelf->_initializer resolveWithStack:resolvingStack model:model];
                                         STLog(strongSelf.objectClass, @"Resolving %i injections into a %@", strongSelf->_dependencies.count, NSStringFromClass(strongSelf.objectClass));
                                         for (ALCDependencyRef *ref in strongSelf->_dependencies) {
                                             // Class dependencies start a new stack.
                                             [resolvingStack addObject:str(@"%@.%@", strongSelf.defaultModelKey, ref.name)];

                                             //NSMutableArray *newStack = [@[str(@"%@.%@", strongSelf.defaultModelKey, ref.name)] mutableCopy];
                                             //[ref.dependency resolveWithStack:newStack model:model];
                                             [ref.dependency resolveWithStack:resolvingStack model:model];
                                             [resolvingStack removeLastObject];
                                         }
                                     }];
}

-(BOOL) ready {
    if (super.ready && (!_initializer || _initializer.ready)) {
        return [self dependenciesReady:[self referencedDependencies] checkingStatusFlag:&_checkingReadyStatus];
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

-(ALCObjectCompletion) objectCompletion {
    blockSelf;
    return ^(ALCObjectCompletionArgs){
        if (strongSelf->_initializer) {
            ALCObjectCompletion completion = strongSelf->_initializer.objectCompletion;
            if (completion) {
                completion(object);
            }
        }
        [ALCRuntime executeSimpleBlock:[strongSelf injectDependenciesIntoObject:object]];
    };
}

-(NSArray<id<ALCDependency>> *) referencedDependencies {
    NSMutableArray *deps = [NSMutableArray arrayWithCapacity:_dependencies.count];
    for (ALCDependencyRef *ref in _dependencies) {
        [deps addObject:ref.dependency];
    }
    return deps;
}

-(ALCSimpleBlock) injectDependenciesIntoObject:(id) value {

    STLog(self.objectClass, @"Injecting dependencies into a %@", NSStringFromClass(self.objectClass));

    NSMutableArray<ALCSimpleBlock> *completions = [[NSMutableArray alloc] init];
    for (ALCDependencyRef *depRef in _dependencies) {
        [ALCRuntime executeSimpleBlock:[depRef.dependency setObject:value variable:depRef.ivar]];
    }

    return [completions combineSimpleBlocks];
}

-(NSString *) description {
    return str(@"%@ class %@", super.description, self.defaultModelKey);
}

@end
