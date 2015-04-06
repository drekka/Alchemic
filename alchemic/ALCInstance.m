//
//  ALCConstructorInfo.m
//  alchemic
//
//  Created by Derek Clarkson on 23/02/2015.
//  Copyright (c) 2015 Derek Clarkson. All rights reserved.
//

#import "ALCInstance.h"

@class ALCDependency;

@implementation ALCInstance

-(instancetype) initWithClass:(Class) class {
    self = [super init];
    if (self) {
        _forClass = class;
    }
    return self;
}



@end
