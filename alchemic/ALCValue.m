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

+(ALCValue *) withValueType:(ALCValueType) valueType
                      value:(id) value
                 completion:(nullable ALCSimpleBlock) completion {
    ALCValue *alcValue = [[ALCValue alloc] init];
    alcValue.type = valueType;
    alcValue->_value = value;
    alcValue->_completion = completion;
    return alcValue;
}

+(ALCValue *) withType:(ALCType *) type
                 value:(id) value
            completion:(nullable ALCSimpleBlock) completion {
    return [self withValueType:type.type value:value completion:completion];
}

@end

NS_ASSUME_NONNULL_END
