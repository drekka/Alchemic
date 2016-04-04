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
                          initializer:(SEL) initializer
                                 args:(NSArray<id<ALCDependency>> *) arguments {
    self = [super init];
    if (self) {
        objectFactory.initializer = self;
        _objectClass = objectFactory.objectClass;
        _initializer = initializer;
        _arguments = arguments;
    }
    return self;
}

-(void)resolveWithStack:(NSMutableArray<NSString *> *)resolvingStack model:(id<ALCModel>) model {
    [self resolveFactoryWithResolvingStack:resolvingStack
                              resolvedFlag:&_resolved
                                     block:^{
                                         [self->_arguments enumerateObjectsUsingBlock:^(NSObject<ALCDependency> *argument, NSUInteger idx, BOOL *stop) {
                                             [argument resolveDependencyWithResolvingStack:resolvingStack
                                                                                  withName:str(@"arg: %lu", idx)
                                                                                     model:model];
                                         }];
                                     }];
}

-(ALCInstantiation *) objectInstantiation {
    STLog(self.objectClass, @"Instantiating a %@ using %@", NSStringFromClass(self.objectClass), NSStringFromSelector(_initializer));
    STStartScope(self.objectClass);
    id obj = [self.objectClass invokeSelector:_initializer arguments:_arguments];
    return [ALCInstantiation instantiationWithObject:obj completion:NULL];
}

-(NSString *) defaultName {
    return [ALCRuntime selectorDescription: self.objectClass selector:_initializer];
}

-(NSString *) descriptionAttributes {
    return str(@"initializer %@", self.defaultName);
}

-(BOOL) ready {
    return [self dependenciesReady:_arguments checkingStatusFlag:&_checkingReadyStatus];
}

@end
