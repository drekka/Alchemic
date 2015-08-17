//
//  NSObject+Alchemic.m
//  alchemic
//
//  Created by Derek Clarkson on 15/08/2015.
//  Copyright © 2015 Derek Clarkson. All rights reserved.
//

@import ObjectiveC;

#import "NSObject+Alchemic.h"
#import <StoryTeller/StoryTeller.h>
#import "ALCInternalMAcros.h"

@implementation NSObject (Alchemic)

-(id) invokeSelector:(SEL) selector arguments:(NSArray *) arguments {

    // Get an invocation ready.
    STLog(ALCHEMIC_LOG, @"Creating an invocation using selector %@", NSStringFromSelector(selector));
    NSMethodSignature *sig = [[self class] instanceMethodSignatureForSelector:selector];
    NSInvocation *inv = [NSInvocation invocationWithMethodSignature:sig];
    inv.selector = selector;

    // Load the arguments.
    [arguments enumerateObjectsUsingBlock:^(id value, NSUInteger idx, BOOL *stop) {
        [inv setArgument:&value atIndex:(NSInteger) idx + 2];
    }];

    [inv invokeWithTarget:self];

    id __unsafe_unretained returnObj;
    [inv getReturnValue:&returnObj];
    STLog(ALCHEMIC_LOG, @"Returning a %s", class_getName([returnObj class]));
    return returnObj;
}


@end
