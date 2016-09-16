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

@implementation ALCValue {
    id _rawValue;
}

+(ALCValue *) withValue:(id) value
             completion:(nullable ALCSimpleBlock) completion {

    // First look for NSValues: Check both NSValue and NSNumber because NSNumber is decended from NSValue.
    if ([value isKindOfClass:[NSValue class]] && ![value isKindOfClass:[NSNumber class]]) {
        ALCType *type = [ALCType typeWithEncoding:((NSValue *) value).objCType];
        return [self withValueType:type.type value:value completion:completion];

    } else if ([value isKindOfClass:[NSArray class]]) {
        return [self withValueType:ALCValueTypeArray value:value completion:completion];

    } else {
        return [self withValueType:ALCValueTypeObject value:value completion:completion];
    }
}

+(ALCValue *) withValueType:(ALCValueType) valueType
                      value:(id) value
                 completion:(nullable ALCSimpleBlock) completion {
    ALCValue *alcValue = [[ALCValue alloc] init];
    alcValue.type = valueType;
    alcValue->_rawValue = value;
    alcValue->_completion = completion;
    return alcValue;
}

-(NSString *) methodNameFragment {
    if (self.type == ALCValueTypeStruct) {
        return [self structNameFromEncoding:((NSValue *)self.value).objCType];
    }
    return super.methodNameFragment;
}

@end

NS_ASSUME_NONNULL_END
