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
#import "ALCFactoryResult.h"

@implementation ALCClassObjectFactoryInitializer {
    NSArray<id<ALCDependency>> *_arguments;
    SEL _initializer;
    BOOL _enumeratingDependencies;
}

-(ALCFactoryResult *) factoryResult {
    STLog(self.objectClass, @"Instantiating a %@ using %@", NSStringFromClass(self.objectClass), NSStringFromSelector(_initializer));
    STStartScope(self.objectClass);
    id obj = [self.objectClass invokeSelector:_initializer arguments:_arguments];
    return [ALCFactoryResult resultWithObject:obj
                                   completion:^{

                                   }];
}

-(NSString *) defaultName {
    return str(@"%@::%@", NSStringFromClass(self.objectClass), NSStringFromSelector(_initializer));
}

-(NSString *) descriptionAttributes {
    return [NSString stringWithFormat:@"initializer %@", self.defaultName];
}

-(instancetype) init {
    return nil;
}

-(instancetype) initWithClass:(Class) objectClass {
    return nil;
}

-(instancetype) initWithObjectFactory:(ALCClassObjectFactory *) objectFactory
                          initializer:(SEL) initializer
                                 args:(NSArray<id<ALCDependency>> *) arguments {
    self = [super initWithClass:objectFactory.objectClass];
    if (self) {
        objectFactory.initializer = self;
        _initializer = initializer;
        _arguments = arguments;
    }
    return self;
}

-(void)resolveWithStack:(NSMutableArray<NSString *> *)resolvingStack model:(id<ALCModel>)model {
    [self resolveFactoryWithResolvingStack:resolvingStack
                        resolvingFlag:&_enumeratingDependencies
                                block:^{
                                    [self->_arguments enumerateObjectsUsingBlock:^(NSObject<ALCDependency> *argument, NSUInteger idx, BOOL *stop) {
                                        [argument resolveDependencyWithResolvingStack:resolvingStack withName:str(@"arg: %lu", idx) model:model];
                                    }];
                                }];
}

-(BOOL) ready {
    if (!super.ready) {
        return NO;
    }
    return [self dependenciesReady:_arguments resolvingFlag:&_enumeratingDependencies];
}

@end
