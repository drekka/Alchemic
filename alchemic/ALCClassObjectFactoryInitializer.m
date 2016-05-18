//
//  ALCObjectFactoryInitializer.m
//  Alchemic
//
//  Created by Derek Clarkson on 25/02/2016.
//  Copyright © 2016 Derek Clarkson. All rights reserved.
//

#import <StoryTeller/StoryTeller.h>

#import "ALCClassObjectFactoryInitializer.h"

#import "ALCClassObjectFactory.h"
#import "ALCInternalMacros.h"
#import "ALCDependency.h"
#import "NSObject+Alchemic.h"
#import "ALCInstantiation.h"
#import "ALCRuntime.h"
#import "NSArray+Alchemic.h"

@implementation ALCClassObjectFactoryInitializer {
    NSArray<id<ALCDependency>> *_arguments;
    SEL _initializer;
    BOOL _resolved;
    BOOL _checkingReadyStatus;
}

@synthesize objectClass = _objectClass;

-(instancetype) init {
    return nil;
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
    blockSelf;
    [self resolveWithResolvingStack:resolvingStack
                       resolvedFlag:&_resolved
                              block:^{
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
    return [ALCRuntime selectorDescription: self.objectClass selector:_initializer];
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
