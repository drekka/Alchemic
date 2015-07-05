//
//  ALCClassMatcher.m
//  alchemic
//
//  Created by Derek Clarkson on 6/04/2015.
//  Copyright (c) 2015 Derek Clarkson. All rights reserved.
//

#import <Alchemic/ALCQualifier.h>

@implementation ALCQualifier {
    Class __nonnull _class;
}

+(nonnull instancetype) qualifierWithValue:(id __nonnull) value {
    ALCQualifier *qualifier = [[ALCQualifier alloc] init];
    qualifier->_value = value;
    return qualifier;
}

-(NSString *) description {
    return [@"Arg: %s" stringByAppendingString:[_value description]];
}

@end
