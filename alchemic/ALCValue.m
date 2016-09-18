//
//  ALCValue.m
//  Alchemic
//
//  Created by Derek Clarkson on 22/03/2016.
//  Copyright © 2016 Derek Clarkson. All rights reserved.
//

#import <Alchemic/ALCValue.h>
#import <Alchemic/ALCType.h>

NS_ASSUME_NONNULL_BEGIN

@implementation ALCValue

+(ALCValue *) withValue:(id) value
             completion:(nullable ALCSimpleBlock) completion {
    ALCValue *alcValue = [[ALCValue alloc] init];
    alcValue->_completion = completion;
    alcValue->_value = value;
    return alcValue;
}

@end

NS_ASSUME_NONNULL_END
