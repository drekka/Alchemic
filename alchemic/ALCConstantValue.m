//
//  ALCConstantValue.m
//  Alchemic
//
//  Created by Derek Clarkson on 14/07/2015.
//  Copyright © 2015 Derek Clarkson. All rights reserved.
//

#import "ALCConstantValue.h"

@implementation ALCConstantValue

+(instancetype) constantValue:(id) value {
    ALCConstantValue *constantValue = [[ALCConstantValue alloc] init];
    constantValue->_value = value == nil ? [NSNull null] : value;
    return constantValue;
}

@end
