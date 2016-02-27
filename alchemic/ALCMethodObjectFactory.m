//
//  ALCMethodObjectFactory.m
//  Alchemic
//
//  Created by Derek Clarkson on 12/02/2016.
//  Copyright © 2016 Derek Clarkson. All rights reserved.
//

#import "ALCMethodObjectFactory.h"

#import "ALCInternalMacros.h"
#import "NSObject+Alchemic.h"
#import "NSMutableArray+Alchemic.h"
#import "ALCClassObjectFactory.h"
#import "ALCDependency.h"

NS_ASSUME_NONNULL_BEGIN

@implementation ALCMethodObjectFactory {
    ALCClassObjectFactory *_parentObjectFactory;
    NSArray<id<ALCDependency>> *_arguments;
    SEL _selector;
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

    // First resolve the parent factory.
    [resolvingStack resolve:_parentObjectFactory model:model];

    // Now the arguments.
    [_arguments enumerateObjectsUsingBlock:^(id<ALCDependency> argument, NSUInteger idx, BOOL *stop) {
        NSString *desc = str(@"Selector %@, Arg %lu", NSStringFromSelector(self->_selector), idx);
        [resolvingStack resolve:argument resolvableName:desc model:model];
    }];
}

-(BOOL) ready {
    if (super.ready && _parentObjectFactory.ready) {
        for (id<ALCResolvable> argument in _arguments) {
            if (!argument.ready) {
                return NO;
            }
        }
        return YES;
    }
    return NO;
}

-(id) instantiateObject {
    return [_parentObjectFactory.object invokeSelector:_selector arguments:_arguments];
}

-(void) setObject:(id) object {
    [_parentObjectFactory injectDependenciesIntoObject:object];
    super.object = object;
}

@end

NS_ASSUME_NONNULL_END
