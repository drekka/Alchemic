//
//  ALCNameMatcher.m
//  alchemic
//
//  Created by Derek Clarkson on 6/04/2015.
//  Copyright (c) 2015 Derek Clarkson. All rights reserved.
//

#import "ALCNameMatcher.h"
#import "ALCResolvableObject.h"

@implementation ALCNameMatcher {
    NSString *_name;
}

-(instancetype) initWithName:(NSString *) name {
    self = [super init];
    if (self) {
        _name = name;
    }
    return self;
}

-(BOOL) matches:(id <ALCResolvable>) resolvable withName:(NSString *) name {
    return [name isEqualToString:_name];
}

@end
