//
//  NSInvocation+Alchemic.m
//  Alchemic
//
//  Created by Derek Clarkson on 18/8/16.
//  Copyright © 2016 Derek Clarkson. All rights reserved.
//

#import "NSInvocation+Alchemic.h"

#import <Alchemic/ALCRuntime.h>

NS_ASSUME_NONNULL_BEGIN

@implementation NSInvocation (Alchemic)

-(BOOL) setArgIndex:(int) idx
             ofType:(Class) type
          allowNils:(BOOL) allowNil
              value:(nullable id) value
              error:(NSError * __autoreleasing _Nullable *) error {
    id finalValue = [ALCRuntime mapValue:value allowNils:allowNil type:(Class) type error:error];
    if (finalValue) {
        [self setArgument:&finalValue atIndex:idx + 2];
    }
    return !*error;
}

@end

NS_ASSUME_NONNULL_END
