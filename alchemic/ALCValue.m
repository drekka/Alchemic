//
//  ALCValue.m
//  Alchemic
//
//  Created by Derek Clarkson on 22/03/2016.
//  Copyright © 2016 Derek Clarkson. All rights reserved.
//

#import "ALCValue.h"

NS_ASSUME_NONNULL_BEGIN

@implementation ALCValue

-(instancetype) initWithType:(ALCType *) type
                       value:(NSValue *) value
                  completion:(nullable ALCSimpleBlock) completion {
    self = [super initWithType:type.type
               typeDescription:type.typeDescription
                    scalarType:type.scalarType
                     objcClass:type.objcClass
                 objcProtocols:type.objcProtocols];
    if (self) {
        _value = value;
        _completion = completion;
    }
    return self;
}

+(ALCValue *) valueWithType:(ALCType *) type
                      value:(NSValue *) value
                 completion:(nullable ALCSimpleBlock) completion {
    return [[ALCValue alloc] initWithType:type value:value completion:completion];
}

@end

NS_ASSUME_NONNULL_END
