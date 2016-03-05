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

NS_ASSUME_NONNULL_BEGIN

@implementation ALCMethodObjectFactory {
    ALCClassObjectFactory *_parentObjectFactory;
    NSArray<id<ALCDependency>> *_arguments;
    SEL _selector;
    BOOL _enumeratingDependencies;
}

-(instancetype) initWithClass:(Class) objectClass
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
    return str(@"%@::%@", NSStringFromClass(_parentObjectFactory.objectClass), NSStringFromSelector(_selector));
}

-(NSString *) descriptionAttributes {
    return [NSString stringWithFormat:@"method %@", self.defaultName];
}

-(void) resolveDependenciesWithStack:(NSMutableArray<NSString *> *) resolvingStack model:(id<ALCModel>) model {
    [self resolveFactoryWithResolvingStack:resolvingStack
                             resolvingFlag:&_enumeratingDependencies
                                     block:^{
                                         [self->_parentObjectFactory resolveWithStack:resolvingStack model:model];
                                         [self->_arguments enumerateObjectsUsingBlock:^(NSObject<ALCDependency> *argument, NSUInteger idx, BOOL *stop) {
                                             [argument resolveDependencyWithResolvingStack:resolvingStack withName:str(@"arg: %lu", idx) model:model];
                                         }];
                                     }];
}

-(BOOL) ready {
    if (super.ready && _parentObjectFactory.ready) {
        return [self dependenciesReady:_arguments resolvingFlag:&_enumeratingDependencies];
    }
    return NO;
}

-(id) instantiateObject {
    STLog(self.objectClass, @"Executing %@::%@", NSStringFromClass(self.objectClass), NSStringFromSelector(_selector));
    STStartScope(self.objectClass);
    return [_parentObjectFactory.object invokeSelector:_selector arguments:_arguments];
}

-(void) setObject:(id) object {
    [_parentObjectFactory injectDependenciesIntoObject:object];
    super.object = object;
}

@end

NS_ASSUME_NONNULL_END
