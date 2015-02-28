//
//  ALCRuntimeFunctions.c
//  alchemic
//
//  Created by Derek Clarkson on 26/02/2015.
//  Copyright (c) 2015 Derek Clarkson. All rights reserved.
//

#include "ALCRuntimeFunctions.h"
#import <objc/runtime.h>

BOOL class_decendsFromClass(Class child, Class parent) {
    Class nextParent = child;
    while(nextParent) {
        if(nextParent == parent) {
            return YES;
        }
        nextParent = class_getSuperclass(nextParent);
    }
    return NO;
}

