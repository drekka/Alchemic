//
//  ALCNameMatcher.m
//  alchemic
//
//  Created by Derek Clarkson on 6/04/2015.
//  Copyright (c) 2015 Derek Clarkson. All rights reserved.
//

#import <Alchemic/ALCNameMatcher.h>
#import "ALCClassBuilder.h"

@implementation ALCNameMatcher {
    NSString *_name;
}

+(instancetype) matcherWithName:(NSString *)name {
    ALCNameMatcher *matcher = [[ALCNameMatcher alloc] init];
    matcher->_name = name;
    return matcher;
}

-(BOOL) matches:(id <ALCBuilder>) builder withName:(NSString *) name {
    return [name isEqualToString:_name];
}

-(NSString *) description {
    return [NSString stringWithFormat:@"Name matcher: '%@'", _name];
}

@end
