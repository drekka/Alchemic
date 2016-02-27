//
//  ALCObjectFactoryInitializer.m
//  Alchemic
//
//  Created by Derek Clarkson on 25/02/2016.
//  Copyright © 2016 Derek Clarkson. All rights reserved.
//

#import "ALCClassObjectFactoryInitializer.h"

#import "ALCInternalMacros.h"
#import "ALCDependency.h"
#import "NSObject+Alchemic.h"
#import "NSMutableArray+Alchemic.h"

@implementation ALCClassObjectFactoryInitializer {
    NSArray<id<ALCDependency>> *_arguments;
    SEL _initializer;
}

-(id) object {
    return [self.objectClass invokeSelector:_initializer arguments:_arguments];
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

-(instancetype) initWithClass:(Class) objectClass
                  initializer:(SEL) initializer
                         args:(NSArray<id<ALCDependency>> *) arguments {
    self = [super initWithClass:objectClass];
    if (self) {
        _initializer = initializer;
        _arguments = arguments;
    }
    return self;
}

-(void) resolveDependenciesWithStack:(NSMutableArray<NSString *> *) resolvingStack model:(id<ALCModel>) model {
    [_arguments enumerateObjectsUsingBlock:^(id<ALCDependency> argument, NSUInteger idx, BOOL *stop) {
        NSString *desc = str(@"Selector %@, Arg %lu", NSStringFromSelector(self->_initializer), idx);
        [resolvingStack resolve:argument resolvableName:desc model:model];
    }];
}

-(BOOL) ready {
    for (id<ALCResolvable> argument in _arguments) {
        if (!argument.ready) {
            return NO;
        }
    }
    return YES;
}

@end
