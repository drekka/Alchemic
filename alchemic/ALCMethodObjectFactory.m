//
//  ALCMethodObjectFactory.m
//  Alchemic
//
//  Created by Derek Clarkson on 12/02/2016.
//  Copyright © 2016 Derek Clarkson. All rights reserved.
//

#import "ALCMethodObjectFactory.h"
#import "ALCDependencyStackItem.h"
#import "ALCInternalMacros.h"
#import "NSObject+Alchemic.h"
#import "ALCClassObjectFactory.h"

@implementation ALCMethodObjectFactory {
    ALCClassObjectFactory *_parentObjectFactory;
    NSArray<id<ALCResolvable>> *_arguments;
    SEL _selector;
}

-(instancetype) initWithClass:(Class) objectClass
          parentObjectFactory:(ALCClassObjectFactory *) parentObjectFactory
                     selector:(SEL) selector
                         args:(nullable NSArray<id<ALCResolvable>> *) arguments {
    self = [super initWithClass:objectClass];
    if (self) {
        _parentObjectFactory = parentObjectFactory;
        _selector = selector;
        _arguments = arguments;
    }
    return self;
}

-(NSString *) defaultName {
    return str(@"%@::%@", NSStringFromClass(_parentObjectFactory.objectClass), NSStringFromClass(self.objectClass));
}

-(NSString *) descriptionAttributes {
    return [NSString stringWithFormat:@"method %@", self.defaultName];
}

-(void) resolveDependenciesWithStack:(NSMutableArray<ALCDependencyStackItem *> *) resolvingStack model:(id<ALCModel>) model {

    // First resolve the parent factory.
    NSString *depDesc = str(@"Method factory %@.%@", NSStringFromClass(_parentObjectFactory.objectClass), NSStringFromSelector(self->_selector));
    [self resolve:_parentObjectFactory withStack:resolvingStack description:depDesc model:model];

    // Now the arguments.
    [_arguments enumerateObjectsUsingBlock:^(id<ALCResolvable> argument, NSUInteger idx, BOOL *stop) {
        NSString *desc = str(@"Selector %@, Arg %lu", NSStringFromSelector(self->_selector), idx);
        [self resolve:argument withStack:resolvingStack description:desc model:model];
    }];
}

-(bool) ready {
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
