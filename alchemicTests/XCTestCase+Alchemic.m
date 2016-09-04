//
//  XCTestCase+Alchemic.m
//  alchemic
//
//  Created by Derek Clarkson on 18/05/2016.
//  Copyright © 2016 Derek Clarkson. All rights reserved.
//

#import "XCTestCase+Alchemic.h"

@import ObjectiveC;

NS_ASSUME_NONNULL_BEGIN

@implementation XCTestCase (Alchemic)

-(nullable id) getVariable:(NSString *) variable fromObject:(id) obj {
    Ivar ivar = class_getInstanceVariable([obj class], variable.UTF8String);
    return object_getIvar(obj, ivar);
}

-(void) setVariable:(NSString *) variable inObject:(id) obj value:(nullable id) value {
    Ivar ivar = class_getInstanceVariable([obj class], variable.UTF8String);
    object_setIvar(obj, ivar, value);
}

@end

NS_ASSUME_NONNULL_END
