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

@synthesize type = _type;

-(instancetype) initWithType:(ALCType *) type value:(NSValue *) value {
    self = [super initWithType:type.type
               typeDescription:type.typeDescription
                    scalarType:type.scalarType
                     objcClass:type.objcClass
                 objcProtocols:type.objcProtocols];
    if (self) {
        _value = value;
    }
    return self;
}

+(nullable ALCValue *) valueWithType:(ALCType *) type value:(NSValue *) value {
    return [[ALCValue alloc] initWithType:type value:value];
}

@end

NS_ASSUME_NONNULL_END
