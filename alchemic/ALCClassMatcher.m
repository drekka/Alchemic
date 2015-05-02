//
//  ALCClassMatcher.m
//  alchemic
//
//  Created by Derek Clarkson on 6/04/2015.
//  Copyright (c) 2015 Derek Clarkson. All rights reserved.
//

@import ObjectiveC;
#import "ALCClassMatcher.h"
#import "ALCinstance.h"
#import "ALCLogger.h"

@implementation ALCClassMatcher {
    Class _class;
}

-(instancetype) initWithClass:(Class) class {
    self = [super init];
    if (self) {
        logRegistration(@"Creating class matcher for class: %s", class_getName(class));
        _class = class;
    }
    return self;
}

-(BOOL) matches:(ALCInstance *)instance withName:(NSString *) name {
    return [instance.forClass isSubclassOfClass:_class];
}

@end
