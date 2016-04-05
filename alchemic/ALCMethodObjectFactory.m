//
//  ALCMethodObjectFactory.m
//  Alchemic
//
//  Created by Derek Clarkson on 12/02/2016.
//  Copyright © 2016 Derek Clarkson. All rights reserved.
//

#import <StoryTeller/StoryTeller.h>

#import "ALCMethodObjectFactory.h"

#import "ALCInternalMacros.h"
#import "NSObject+Alchemic.h"
#import "ALCClassObjectFactory.h"
#import "ALCDependency.h"
#import "ALCInstantiation.h"
#import "ALCRuntime.h"

NS_ASSUME_NONNULL_BEGIN

@implementation ALCMethodObjectFactory {
    ALCClassObjectFactory *_parentObjectFactory;
    NSArray<id<ALCDependency>> *_arguments;
    SEL _selector;
    BOOL _resolved;
    BOOL _checkingReadyStatus;
}

-(instancetype) initWithClass:(Class)objectClass {
    return nil;
}

-(instancetype) initWithClass:(Class)objectClass
          parentObjectFactory:(ALCClassObjectFactory *) parentObjectFactory
                     selector:(SEL) selector
                         args:(nullable NSArray<id<ALCDependency>> *) arguments {
    self = [super initWithClass:objectClass];
    if (self) {
        _parentObjectFactory = parentObjectFactory;
        _selector = selector;
        _arguments = arguments;
    }
    return self;
}

-(NSString *) defaultName {
    return [ALCRuntime selectorDescription:_parentObjectFactory.objectClass selector:_selector];
}

-(void) resolveDependenciesWithStack:(NSMutableArray<NSString *> *) resolvingStack model:(id<ALCModel>) model {
    blockSelf;
    [self resolveFactoryWithResolvingStack:resolvingStack
                              resolvedFlag:&_resolved
                                     block:^{
                                         [strongSelf->_parentObjectFactory resolveWithStack:resolvingStack model:model];
                                         [strongSelf->_arguments enumerateObjectsUsingBlock:^(NSObject<ALCDependency> *argument, NSUInteger idx, BOOL *stop) {
                                             [argument resolveDependencyWithResolvingStack:resolvingStack
                                                                                  withName:str(@"arg: %lu", idx)
                                                                                     model:model];
                                         }];
                                     }];
}

-(BOOL) ready {
    if (super.ready && _parentObjectFactory.ready) {
        return [self dependenciesReady:_arguments checkingStatusFlag:&_checkingReadyStatus];
    }
    return NO;
}

-(ALCInstantiation *) createObject {
    STStartScope(self.objectClass);
    ALCInstantiation *parentGeneration = _parentObjectFactory.objectInstantiation;
    if (parentGeneration.completion) {
        parentGeneration.completion();
    }
    return [parentGeneration.object invokeSelector:_selector arguments:_arguments];
}

#pragma mark - Descriptions

-(NSString *) descriptionAttributes {
    return str(@"method %@", self.defaultName);
}

@end

NS_ASSUME_NONNULL_END
