//
//  ALCClassMatcher.m
//  alchemic
//
//  Created by Derek Clarkson on 6/04/2015.
//  Copyright (c) 2015 Derek Clarkson. All rights reserved.
//

@import ObjectiveC;
#import <Alchemic/ALCClassMatcher.h>
#import "ALCType.h"

@implementation ALCClassMatcher {
    Class _class;
}

+(instancetype) matcherWithClass:(Class)class {
    ALCClassMatcher *matcher = [[ALCClassMatcher alloc] init];
    matcher->_class = class;
    return matcher;
}

-(BOOL) matches:(id <ALCBuilder>) builder withName:(NSString *) name {
    return [builder.valueType typeIsKindOfClass:_class];
}

-(NSString *) description {
    return [NSString stringWithFormat:@"class matcher: %s", class_getName(_class)];
}

@end
