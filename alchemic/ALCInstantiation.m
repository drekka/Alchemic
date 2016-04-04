//
//  ALCInstantiationResult.m
//  Alchemic
//
//  Created by Derek Clarkson on 9/03/2016.
//  Copyright © 2016 Derek Clarkson. All rights reserved.
//

#import "ALCInstantiation.h"

NS_ASSUME_NONNULL_BEGIN

@implementation ALCInstantiation

+(instancetype) instantiationWithObject:(id) object completion:(nullable ALCSimpleBlock) completion {
    ALCInstantiation *result = [[ALCInstantiation alloc] init];
    result->_object = object;
    result->_completion = completion;
    return result;
}

@end

NS_ASSUME_NONNULL_END
