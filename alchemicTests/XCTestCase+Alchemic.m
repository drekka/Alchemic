//
//  XCTestCase+Alchemic.m
//  alchemic
//
//  Created by Derek Clarkson on 18/05/2016.
//  Copyright © 2016 Derek Clarkson. All rights reserved.
//

#import "XCTestCase+Alchemic.h"

@import ObjectiveC;

@implementation XCTestCase (Alchemic)

-(id) getVariable:(NSString *) variable fromObject:(id) obj {
    Ivar ivar = class_getInstanceVariable([obj class], variable.UTF8String);
    return object_getIvar(obj, ivar);
}

@end
