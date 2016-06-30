//
//  ALCObjectFactoryInitializer.m
//  Alchemic
//
//  Created by Derek Clarkson on 25/02/2016.
//  Copyright © 2016 Derek Clarkson. All rights reserved.
//

@import StoryTeller;

#import <Alchemic/ALCClassObjectFactoryInitializer.h>

#import <Alchemic/ALCClassObjectFactory.h>
#import <Alchemic/ALCMacros.h>
#import <Alchemic/ALCInternalMacros.h>
#import <Alchemic/ALCDependency.h>
#import <Alchemic/NSObject+Alchemic.h>
#import <Alchemic/ALCInstantiation.h>
#import <Alchemic/ALCRuntime.h>
#import <Alchemic/NSArray+Alchemic.h>

@implementation ALCClassObjectFactoryInitializer {
    NSArray<id<ALCDependency>> *_arguments;
    SEL _initializer;
    BOOL _resolved;
    BOOL _checkingReadyStatus;
}

@synthesize objectClass = _objectClass;

-(instancetype) init {
    methodReturningObjectNotImplemented;
}

-(instancetype) initWithObjectFactory:(ALCClassObjectFactory *) objectFactory
                       setInitializer:(SEL) initializer
                                 args:(NSArray<id<ALCDependency>> *) arguments {
    self = [super init];
    if (self) {
        [ALCRuntime validateClass:objectFactory.objectClass selector:initializer arguments:arguments];
        objectFactory.initializer = self;
        _objectClass = objectFactory.objectClass;
        _initializer = initializer;
        _arguments = arguments;
    }
    return self;
}

-(void) resolveWithStack:(NSMutableArray<id<ALCResolvable>> *)resolvingStack model:(id<ALCModel>) model {
    STLog(self.objectClass, @"Resolving initializer %@", [self defaultModelKey]);
    AcWeakSelf;
    [self resolveWithResolvingStack:resolvingStack
                       resolvedFlag:&_resolved
                              block:^{
                                  AcStrongSelf;
                                  [strongSelf->_arguments resolveArgumentsWithStack:resolvingStack model:model];
                              }];
}

-(id) createObject {
    STLog(self.objectClass, @"Instantiating a %@ using %@", NSStringFromClass(self.objectClass), [self defaultModelKey]);
    id obj = [self.objectClass alloc];
    return [obj invokeSelector:_initializer arguments:_arguments];
}

-(ALCObjectCompletion)objectCompletion {
    return NULL;
}

-(NSString *) defaultModelKey {
    return [ALCRuntime class: self.objectClass selectorDescription:_initializer];
}

-(NSString *) description {
    return str(@"initializer %@", self.defaultModelKey);
}

-(NSString *)resolvingDescription {
    return str(@"Initializer %@", self.defaultModelKey);
}

-(BOOL) ready {
    return [_arguments dependenciesReadyWithCurrentlyCheckingFlag:&_checkingReadyStatus];
}

@end
