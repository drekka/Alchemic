//
//  ALCConstructorInfo.m
//  alchemic
//
//  Created by Derek Clarkson on 23/02/2015.
//  Copyright (c) 2015 Derek Clarkson. All rights reserved.
//

#import "ALCInstance.h"
#import <objc/runtime.h>

@class ALCDependency;

@implementation ALCInstance

-(instancetype) initWithClass:(Class) class {
    self = [super init];
    if (self) {
        _forClass = class;
    }
    return self;
}

-(NSString *) debugDescription {
    return [NSString stringWithFormat:@"Instance of %s", class_getName(_forClass)];
}

@end
