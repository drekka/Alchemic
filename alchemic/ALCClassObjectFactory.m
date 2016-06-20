//
//  ALCClassObjectFactory.m
//  Alchemic
//
//  Created by Derek Clarkson on 12/02/2016.
//  Copyright © 2016 Derek Clarkson. All rights reserved.
//

@import StoryTeller;
// :: Framework ::
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
    NSMutableArray<id<ALCDependency>> *_dependencies;
    BOOL _resolved;
    BOOL _checkingReadyStatus;
}

@synthesize initializer = _initializer;

#pragma mark - Life cycle

-(instancetype) initWithClass:(Class) objectClass {
    self = [super initWithClass:objectClass];
    if (self) {
        _dependencies = [[NSMutableArray alloc] init];
    }
    return self;
}

-(void)configureWithOption:(id)option customOptionHandler:(void (^)(id _Nonnull))customOptionHandler {
    if (_initializer && [option isKindOfClass:[ALCIsReference class]]) {
        throwException(IllegalArgument, @"Factories with initializers cannot be set to reference external objects");
    } else {
        [super configureWithOption:option customOptionHandler:customOptionHandler];
    }
}

-(void) registerInjection:(id<ALCInjector>) injector forVariable:(Ivar) variable withName:(NSString *) variableName {
    ALCVariableDependency *ref = [ALCVariableDependency variableDependencyWithInjector:injector
                                                                              intoIvar:variable
                                                                                  name:variableName];
    [_dependencies addObject:ref];
}

-(void)resolveWithStack:(NSMutableArray<id<ALCResolvable>> *)resolvingStack model:(id<ALCModel>) model {
    STLog(self.objectClass, @"Resolving class factory %@", NSStringFromClass(self.objectClass));
    blockSelf;
    [self resolveWithResolvingStack:resolvingStack
                       resolvedFlag:&_resolved
                              block:^{
                                  
                                  [strongSelf->_initializer resolveWithStack:resolvingStack model:model];
                                  
                                  STLog(strongSelf.objectClass, @"Resolving %i injections into a %@", strongSelf->_dependencies.count, NSStringFromClass(strongSelf.objectClass));
                                  for (ALCVariableDependency *ref in strongSelf->_dependencies) {
                                      [resolvingStack addObject:ref];
                                      [ref.injector resolveWithStack:resolvingStack model:model];
                                      [resolvingStack removeLastObject];
                                  }
                              }];
}

-(BOOL) ready {
    if (super.ready && (!_initializer || _initializer.ready)) {
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

-(ALCObjectCompletion) objectCompletion {
    blockSelf;
    return ^(ALCObjectCompletionArgs){
        if (strongSelf->_initializer) {
            ALCObjectCompletion completion = strongSelf->_initializer.objectCompletion;
            if (completion) {
                completion(object);
            }
        }
        
        [self injectDependencies:object];
    };
}

#pragma mark - Tasks

-(void) injectDependencies:(id) object {
    STLog(self.objectClass, @"Injecting dependencies into a %@", NSStringFromClass(self.objectClass));
    for (ALCVariableDependency *dep in _dependencies) {
        [ALCRuntime executeSimpleBlock:[dep injectObject:object]];
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
