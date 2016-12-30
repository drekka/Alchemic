//
//  ALCMethodObjectFactory.m
//  Alchemic
//
//  Created by Derek Clarkson on 12/02/2016.
//  Copyright © 2016 Derek Clarkson. All rights reserved.
//

@import StoryTeller;


#import <Alchemic/ALCMethodObjectFactory.h>

#import <Alchemic/NSArray+Alchemic.h>
#import <Alchemic/NSObject+Alchemic.h>
#import <Alchemic/ALCInternalMacros.h>
#import <Alchemic/Alchemic.h>
#import <Alchemic/ALCType.h>
#import <Alchemic/ALCRuntime.h>
#import <Alchemic/ALCContext+Internal.h>

NS_ASSUME_NONNULL_BEGIN

@implementation ALCMethodObjectFactory {
    NSArray<id<ALCDependency>> *_arguments;
    BOOL _resolved;
    BOOL _checkingReadyStatus;
}

#pragma mark - Life cycle

-(instancetype) initWithType:(ALCType *) type {
    methodReturningObjectNotImplemented;
}

-(instancetype) initWithType:(ALCType *) type
         parentObjectFactory:(ALCClassObjectFactory *) parentObjectFactory
                    selector:(SEL) selector
                        args:(nullable NSArray<id<ALCDependency>> *) arguments {
    self = [super initWithType:type];
    if (self) {
        [ALCRuntime validateClass:parentObjectFactory.type.objcClass selector:selector numberOfArguments:arguments.count];
        _parentObjectFactory = parentObjectFactory;
        _selector = selector;
        _arguments = arguments;
    }
    return self;
}

-(NSString *) defaultModelName {
    return [ALCRuntime forClass:_parentObjectFactory.type.objcClass selectorDescription:_selector];
}

-(void)configureWithOption:(id)option model:(id<ALCModel>) model {
    if ([option isKindOfClass:[ALCIsReference class]]) {
        throwException(AlchemicIllegalArgumentException, @"Method based factories cannot be set to reference external objects");
    } else {
        [super configureWithOption:option model:model];
    }
}

-(void) resolveDependenciesWithStack:(NSMutableArray<id<ALCResolvable>> *) resolvingStack model:(id<ALCModel>) model {
    STStartScope(self.type);
    AcWeakSelf;
    [self resolveWithStack:resolvingStack
              resolvedFlag:&_resolved
                     block:^{
                         AcStrongSelf;
                         [strongSelf->_parentObjectFactory resolveWithStack:resolvingStack model:model];
                         [strongSelf->_arguments resolveWithStack:resolvingStack model:model];
                     }];
}

-(BOOL) isReady {
    if (super.isReady && _parentObjectFactory.isReady) {
        return [_arguments dependenciesReadyWithCheckingFlag:&_checkingReadyStatus];
    }
    return NO;
}

-(id) createObject {

    STStartScope(self.type);

    ALCValue *parentValue = _parentObjectFactory.value;
    id parentObj = parentValue.object;
    if (!parentObj) {
        throwException(AlchemicNilParentObjectException, @"Parent object of method is nil.");
    }

    [parentValue complete];
    return [(NSObject *) parentObj invokeSelector:_selector arguments:_arguments];
}

-(ALCBlockWithObject) objectCompletion {
    return ^(ALCBlockWithObjectArgs){
        STLog(self, @"Completing method execution");
        [(ALCContextImpl *)[Alchemic mainContext] injectDependencies:object searchCriteria:@[]];
    };
}

#pragma mark - Descriptions

-(NSString *) description {
    return str(@"%@  M] %@ -> %@", super.description, self.defaultModelName, NSStringFromClass(self.type.objcClass));
}

-(NSString *)resolvingDescription {
    return str(@"Method %@", self.defaultModelName);
}

@end

NS_ASSUME_NONNULL_END
