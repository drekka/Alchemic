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
    blockSelf;
    [self resolveFactoryWithResolvingStack:resolvingStack
                              resolvedFlag:&_resolved
                                     block:^{
                                         if (strongSelf->_initializer) {
                                             [strongSelf->_initializer resolveWithStack:resolvingStack model:model];
                                         }
                                         for (ALCDependencyRef *ref in strongSelf->_dependencies) {
                                             // Class dependencies start a new stack.
                                             NSMutableArray *newStack = [[NSMutableArray alloc] init];
                                             [ref.dependency resolveDependencyWithResolvingStack:newStack
                                                                                        withName:str(@"%@.%@", strongSelf.defaultName, ref.name)
                                                                                           model:model];
                                         }
                                     }];
}

-(BOOL) ready {
    if (super.ready && (!_initializer || _initializer.ready)) {
        return [self dependenciesReady:[self referencedDependencies] checkingStatusFlag:&_checkingReadyStatus];
    }
    return NO;
}

-(ALCInstantiation *) createObject {

    id obj;
    ALCSimpleBlock initializerCompletion = NULL;
    if (_initializer) {
        ALCInstantiation *initializerResult = _initializer.objectInstantiation;
        obj = initializerResult.object;
        initializerCompletion = initializerResult.completion;
    } else {
        STLog(self.objectClass, @"Instantiating a %@ using init", NSStringFromClass(self.objectClass));
        obj = [[self.objectClass alloc] init];
    }

    blockSelf;
    return [ALCInstantiation instantiationWithObject:obj
                                          completion:^{

                                              STLog(strongSelf.objectClass, @"Executing completion for a %@", NSStringFromClass(strongSelf.objectClass));
                                              if (initializerCompletion) {
                                                  initializerCompletion();
                                              }

                                              [strongSelf injectDependenciesIntoObject:obj];
                                              [strongSelf objectFinished:obj];
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
    STLog(self.objectClass, @"Injecting dependencies into a %@", NSStringFromClass(self.objectClass));
    for (ALCDependencyRef *depRef in _dependencies) {
        STLog(self.objectClass, @"Injecting %@", [ALCRuntime propertyDescription:self.objectClass property:depRef.name]);
        ALCSimpleBlock completion = [depRef.dependency setObject:value variable:depRef.ivar];
        if (completion) {
            completion();
        }
    }
}

@end
