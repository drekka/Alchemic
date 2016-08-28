//
//  ALCObjectFactoryInitializer.m
//  Alchemic
//
//  Created by Derek Clarkson on 25/02/2016.
//  Copyright © 2016 Derek Clarkson. All rights reserved.
//

@import StoryTeller;

#import "ALCClassObjectFactoryInitializer.h"

#import "ALCClassObjectFactory.h"
#import "ALCMacros.h"
#import "ALCInternalMacros.h"
#import "ALCDependency.h"
#import "NSObject+Alchemic.h"
#import "ALCInstantiation.h"
#import "ALCRuntime.h"
#import "NSArray+Alchemic.h"
#import "ALCType.h"

@implementation ALCClassObjectFactoryInitializer {
    NSArray<id<ALCDependency>> *_arguments;
    BOOL _resolved;
    BOOL _checkingReadyStatus;
}

@synthesize type = _type;

-(instancetype) init {
    methodReturningObjectNotImplemented;
}

-(instancetype) initWithObjectFactory:(ALCClassObjectFactory *) objectFactory
                          initializer:(SEL) initializer
                                 args:(nullable NSArray<id<ALCDependency>> *) arguments {
    self = [super init];
    if (self) {
        objectFactory.initializer = self;
        _type = objectFactory.type;
        _initializer = initializer;
        _arguments = arguments.count == 0 ? nil : arguments;
        [ALCRuntime validateClass:_type.objcClass selector:initializer numberOfArguments:arguments.count];
    }
    return self;
}

-(void) resolveWithStack:(NSMutableArray<id<ALCResolvable>> *)resolvingStack model:(id<ALCModel>) model {
    STLog(_type, @"Resolving initializer %@", [self defaultModelName]);
    AcWeakSelf;
    [self resolveWithStack:resolvingStack
              resolvedFlag:&_resolved
                     block:^{
                         AcStrongSelf;
                         [strongSelf->_arguments resolveWithStack:resolvingStack model:model];
                     }];
}

-(id) createObject {
    STLog(_type, @"Instantiating a %@ using %@", NSStringFromClass(_type.objcClass), [self defaultModelName]);
    id obj = [_type.objcClass alloc];
    return [obj invokeSelector:_initializer arguments:_arguments];
}

-(ALCBlockWithObject) objectCompletion {
    return NULL;
}

-(NSString *) defaultModelName {
    return [ALCRuntime forClass: _type.objcClass selectorDescription:_initializer];
}

-(NSString *) description {
    return str(@"initializer %@", self.defaultModelName);
}

-(NSString *) resolvingDescription {
    return [self description];
}

-(BOOL) isReady {
    return !_arguments || [_arguments dependenciesReadyWithCheckingFlag:&_checkingReadyStatus];
}

@end
