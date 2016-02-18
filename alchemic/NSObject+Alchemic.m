//
//  NSObject+Alchemic.m
//  Alchemic
//
//  Created by Derek Clarkson on 7/02/2016.
//  Copyright © 2016 Derek Clarkson. All rights reserved.
//

#import "NSObject+Alchemic.h"
#import "ALCResolvable.h"
#import "ALCRuntime.h"
#import "ALCInternalMacros.h"

@implementation NSObject (Alchemic)

-(void) injectVariable:(Ivar) variable withResolvable:(id<ALCResolvable>) resolvable {
    Class iVarClass = [ALCRuntime classForIVar:variable];
    id value = resolvable.object;

    // Wrap the value in an array if it's not an array and ivar is.
    if ([iVarClass isSubclassOfClass:[NSArray class]] && ![value isKindOfClass:[NSArray class]]) {
        value = @[value];
    }

    if (![value isKindOfClass:iVarClass]) {
        @throw [NSException exceptionWithName:@"AlchemicIncorrectType"
                                       reason:str(@"Resolved value of type %2$@ cannot be cast to variable '%1$s' (%3$s)", ivar_getName(variable), NSStringFromClass([value class]), class_getName(iVarClass))
                                     userInfo:nil];
    }

    object_setIvar(self, variable, value);
}

-(id) invokeSelector:(SEL) selector arguments:(NSArray *) arguments {

    // Get an invocation ready.
    NSMethodSignature *sig = [[self class] instanceMethodSignatureForSelector:selector];
    NSInvocation *inv = [NSInvocation invocationWithMethodSignature:sig];
    inv.selector = selector;

    // Load the arguments.
    [arguments enumerateObjectsUsingBlock:^(id value, NSUInteger idx, BOOL *stop) {
        id finalValue = [value isKindOfClass:[NSNull class]] ? nil : value;
        [inv setArgument:&finalValue atIndex:(NSInteger) idx + 2];
    }];

    [inv invokeWithTarget:self];

    id __unsafe_unretained returnObj;
    [inv getReturnValue:&returnObj];
    return returnObj;
}

+(id) invokeSelector:(SEL) selector arguments:(NSArray *) arguments {
    return [self invokeSelector:selector arguments:arguments];
}

@end
