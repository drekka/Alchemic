//
//  ALCSimpleObjectFactory.m
//  alchemic
//
//  Created by Derek Clarkson on 23/02/2015.
//  Copyright (c) 2015 Derek Clarkson. All rights reserved.
//

#import "ALCSimpleObjectFactory.h"
#import "ALCLogger.h"
#import <objc/runtime.h>

@implementation ALCSimpleObjectFactory

-(id) createObjectFromClassInfo:(ALCClassInfo *) classInfo {
    logCreation(@"Creating singleton for class %s using init", class_getName(classInfo.forClass));
    return [[classInfo.forClass alloc] init];
}

@end
