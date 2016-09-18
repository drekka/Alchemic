//
//  Template.m
//  Alchemic
//
//  Created by Derek Clarkson on 8/8/16.
//  Copyright © 2016 Derek Clarkson. All rights reserved.
//

#import "Template.h"
@import Alchemic;

@implementation Template {
    int count;
}

static int counter;

AcRegister(AcTemplate)

-(instancetype) init {
    self = [super init];
    if (self) {
        counter++;
        count = counter;
    }
    return self;
}

@end
