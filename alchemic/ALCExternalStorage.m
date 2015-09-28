//
//  ALCExternalStorage.m
//  alchemic
//
//  Created by Derek Clarkson on 24/08/2015.
//  Copyright © 2015 Derek Clarkson. All rights reserved.
//

#import "ALCExternalStorage.h"

@implementation ALCExternalStorage

@synthesize value = _value;

-(id)value {
    if (_value == nil) {
        @throw [NSException exceptionWithName:@"AlchemicCannotCreateValue"
                                       reason:[NSString stringWithFormat:@"%@ Builder is marked as External. Expects an object to be set, not instantiated dynamically.", self]
                                     userInfo:nil];
    }
    return _value;
}

-(BOOL)hasValue {
    return _value != nil;
}

-(NSString *)attributeText {
    return @", external";
}

@end
