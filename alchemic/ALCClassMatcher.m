//
//  ALCClassMatcher.m
//  alchemic
//
//  Created by Derek Clarkson on 6/04/2015.
//  Copyright (c) 2015 Derek Clarkson. All rights reserved.
//

@import ObjectiveC;
#import "ALCClassMatcher.h"
#import "ALCModelObjectInstance.h"

@implementation ALCClassMatcher {
    Class _class;
}

-(instancetype) initWithClass:(Class) class {
    self = [super init];
    if (self) {
        _class = class;
    }
    return self;
}

-(BOOL) matches:(ALCModelObjectInstance *)instance withName:(NSString *) name {
    return [instance.objectClass isSubclassOfClass:_class];
}

@end
