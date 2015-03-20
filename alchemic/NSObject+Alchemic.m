//
//  NSObject+Alchemic.m
//  alchemic
//
//  Created by Derek Clarkson on 18/03/2015.
//  Copyright (c) 2015 Derek Clarkson. All rights reserved.
//

#import "NSObject+Alchemic.h"
#import "ALCObjectProxy.h"
#import <objc/runtime.h>
#import "ALCLogger.h"

@implementation NSObject (Alchemic)

-(void) resolveProxy:(id *) objectVariable {
    id obj = *objectVariable;
    if (object_getClass(obj) == [ALCObjectProxy class]) {
        logObjectResolving(@"Replacing proxy with target object");
        *objectVariable = ((ALCObjectProxy *) obj).proxiedObject;
    }
}

@end
