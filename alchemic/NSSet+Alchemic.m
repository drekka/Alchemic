//
//  NSSet+Alchemic.m
//  Alchemic
//
//  Created by Derek Clarkson on 7/04/2016.
//  Copyright © 2016 Derek Clarkson. All rights reserved.
//

#import "NSSet+Alchemic.h"

NS_ASSUME_NONNULL_BEGIN

@implementation NSSet (Alchemic)

+(void) unionSet:(nullable NSSet *) sourceSet intoMutableSet:(NSMutableSet  * _Nullable * _Nonnull) destSet {
    if (sourceSet) {
        if (!*destSet) {
            *destSet = [[NSMutableSet alloc] init];
        }
        [*destSet unionSet:(NSSet * _Nonnull) sourceSet];
    }
}

@end

NS_ASSUME_NONNULL_END
