//
//  ALCNameMatcher.m
//  alchemic
//
//  Created by Derek Clarkson on 6/04/2015.
//  Copyright (c) 2015 Derek Clarkson. All rights reserved.
//

#import "ALCNameMatcher.h"
#import "ALCInstance.h"
#import "ALCLogger.h"

@implementation ALCNameMatcher {
    NSString *_name;
}

-(instancetype) initWithName:(NSString *) name {
    self = [super init];
    if (self) {
        logRegistration(@"Creating name matcher for name: %@", name);
        _name = name;
    }
    return self;
}

-(BOOL) matches:(ALCInstance *)instance withName:(NSString *) name {
    return [name isEqualToString:_name];
}

@end
