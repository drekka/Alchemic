//
//  ALCSingletonStorage.m
//  alchemic
//
//  Created by Derek Clarkson on 23/08/2015.
//  Copyright © 2015 Derek Clarkson. All rights reserved.
//

#import "ALCBuilderStorageSingleton.h"

@implementation ALCBuilderStorageSingleton

@synthesize value = _value;

-(BOOL)hasValue {
    return _value != nil;
}

-(NSString *)attributeText {
    return [NSString stringWithFormat:@", singleton%@", (self.hasValue ? @", value present" : @"")];
}

@end
