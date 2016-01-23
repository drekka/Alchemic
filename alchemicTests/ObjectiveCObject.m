//
//  ObjectiveCObject.m
//  alchemic
//
//  Created by Derek Clarkson on 9/11/2015.
//  Copyright © 2015 Derek Clarkson. All rights reserved.
//

#import "ObjectiveCObject.h"

@implementation ObjectiveCObject

+(void) setSwiftClass:(Class) swiftClass {
    NSLog(@"Details %@", NSStringFromClass(swiftClass));
}

@end
