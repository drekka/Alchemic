//
//  ALCSingletonStorage.m
//  alchemic
//
//  Created by Derek Clarkson on 23/08/2015.
//  Copyright © 2015 Derek Clarkson. All rights reserved.
//

#import "ALCSingletonStorage.h"

@implementation ALCSingletonStorage

@synthesize value = _value;

-(BOOL)hasValue {
    return _value != nil;
}

-(NSString *)attributeText {
    return @", singleton";
}

@end
