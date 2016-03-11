//
//  ALCInstantiationResult.m
//  Alchemic
//
//  Created by Derek Clarkson on 9/03/2016.
//  Copyright © 2016 Derek Clarkson. All rights reserved.
//

#import "ALCFactoryResult.h"

@implementation ALCFactoryResult

+(instancetype) resultWithObject:(id) object completion:(ALCInstantiationCompletion) completion {
    ALCFactoryResult *result = [[ALCFactoryResult alloc] init];
    result->_object = object;
    result->_completion = completion;
    return result;
}

@end
