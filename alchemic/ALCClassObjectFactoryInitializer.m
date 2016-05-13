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

-(void)resolveWithStack:(NSMutableArray<NSString *> *)resolvingStack model:(id<ALCModel>) model {
    STLog(self.objectClass, @"Resolving initializer %@", [self defaultModelKey]);
    [self resolveFactoryWithResolvingStack:resolvingStack
                              resolvedFlag:&_resolved
                                     block:^{
                                         [self->_arguments enumerateObjectsUsingBlock:^(NSObject<ALCDependency> *argument, NSUInteger idx, BOOL *stop) {
                                             [resolvingStack addObject:str(@"arg: %lu", idx)];
                                             [argument resolveWithStack:resolvingStack model:model];
                                             [resolvingStack removeLastObject];
                                         }];
                                     }];
}

-(id)createObject {
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

-(BOOL) ready {
    return [self dependenciesReady:_arguments checkingStatusFlag:&_checkingReadyStatus];
}

@end
