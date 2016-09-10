//
//  ALCValue.m
//  Alchemic
//
//  Created by Derek Clarkson on 22/03/2016.
//  Copyright © 2016 Derek Clarkson. All rights reserved.
//

#import <Alchemic/ALCValue.h>

NS_ASSUME_NONNULL_BEGIN

@implementation ALCValue

+(ALCValue *) withType:(ALCValueType) type
                 value:(id) value
            completion:(nullable ALCSimpleBlock) completion {
    ALCValue *alcValue = [[ALCValue alloc] init];
    alcValue.type = type;
    alcValue->_value = value;
    alcValue->_completion = completion;
    return alcValue;
}

@end

NS_ASSUME_NONNULL_END
