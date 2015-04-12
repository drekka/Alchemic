//
//  ALCClassMatcher.m
//  alchemic
//
//  Created by Derek Clarkson on 6/04/2015.
//  Copyright (c) 2015 Derek Clarkson. All rights reserved.
//

#import "ALCClassMatcher.h"
#import "ALCRuntime.h"
#import "ALCinstance.h"
#import "ALCLogger.h"

@implementation ALCClassMatcher {
    Class _class;
}

-(instancetype) initWithClass:(Class) class {
    self = [super init];
    if (self) {
        logRegistration(@"Creating class matcher: %s", class_getName(class));
        _class = class;
    }
    return self;
}

-(BOOL) matches:(ALCInstance *)instance withName:(NSString *) name {
    return [ALCRuntime class:instance.forClass extends:_class];
}

@end
