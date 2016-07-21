//
//  ALCMethodObjectFactory.m
//  Alchemic
//
//  Created by Derek Clarkson on 12/02/2016.
//  Copyright © 2016 Derek Clarkson. All rights reserved.
//

@import StoryTeller;

// :: Framework ::
#import "ALCMethodArgumentDependency.h"
#import "ALCClassObjectFactory.h"
#import "ALCMethodObjectFactory.h"
#import <Alchemic/NSArray+Alchemic.h>
#import <Alchemic/NSObject+Alchemic.h>
#import "ALCInternalMacros.h"
#import "ALCFlagMacros.h"
#import "ALCInstantiation.h"
#import "Alchemic.h"
#import "ALCRuntime.h"

NS_ASSUME_NONNULL_BEGIN

@implementation ALCMethodObjectFactory {
    NSArray<id<ALCDependency>> *_arguments;
    BOOL _resolved;
    BOOL _checkingReadyStatus;
}

#pragma mark - Life cycle

-(instancetype) initWithClass:(Class)objectClass {
    methodReturningObjectNotImplemented;
}

-(instancetype) initWithClass:(Class)objectClass
          parentObjectFactory:(ALCClassObjectFactory *) parentObjectFactory
                     selector:(SEL) selector
                         args:(nullable NSArray<id<ALCDependency>> *) arguments {
    self = [super initWithClass:objectClass];
    if (self) {
        [ALCRuntime validateClass:parentObjectFactory.objectClass selector:selector arguments:arguments];
        _parentObjectFactory = parentObjectFactory;
        _selector = selector;
        _arguments = arguments;
    }
    return self;
}

-(NSString *) defaultModelKey {
    return [ALCRuntime class:_parentObjectFactory.objectClass selectorDescription:_selector];
}

-(void)configureWithOption:(id)option model:(id<ALCModel>) model {
    if ([option isKindOfClass:[ALCIsReference class]]) {
        throwException(IllegalArgument, @"Method based factories cannot be set to reference external objects");
    } else {
        [super configureWithOption:option model:model];
    }
}

-(void) resolveDependenciesWithStack:(NSMutableArray<id<ALCResolvable>> *) resolvingStack model:(id<ALCModel>) model {
    AcWeakSelf;
    [self resolveWithResolvingStack:resolvingStack
                       resolvedFlag:&_resolved
                              block:^{
                                  AcStrongSelf;
                                  [strongSelf->_parentObjectFactory resolveWithStack:resolvingStack model:model];
                                  [strongSelf->_arguments resolveArgumentsWithStack:resolvingStack model:model];
                              }];
}

-(BOOL) isReady {
    if (super.isReady && _parentObjectFactory.isReady) {
        return [_arguments dependenciesReadyWithCurrentlyCheckingFlag:&_checkingReadyStatus];
    }
    return NO;
}

-(id) createObject {
    
    STStartScope(self.objectClass);
    
    ALCInstantiation *parentGeneration = _parentObjectFactory.instantiation;
    if (!parentGeneration.object) {
        throwException(NilParentObject, @"Parent object of method is nil.");
    }
    
    [parentGeneration complete];
    return [(NSObject *) parentGeneration.object invokeSelector:_selector arguments:_arguments];
}

-(ALCBlockWithObject) objectCompletion {
    return ^(ALCBlockWithObjectArgs){
        [[Alchemic mainContext] injectDependencies:object];
    };
}

#pragma mark - Descriptions

-(NSString *) description {
    return str(@"%@ method %@ -> %@", super.description, self.defaultModelKey, NSStringFromClass(self.objectClass));
}

-(NSString *)resolvingDescription {
    return str(@"Method %@", self.defaultModelKey);
}

@end

NS_ASSUME_NONNULL_END
