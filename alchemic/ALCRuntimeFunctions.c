//
//  ALCRuntimeFunctions.c
//  alchemic
//
//  Created by Derek Clarkson on 26/02/2015.
//  Copyright (c) 2015 Derek Clarkson. All rights reserved.
//

#include "ALCRuntimeFunctions.h"
#import <objc/runtime.h>
#import "stdio.h"

BOOL class_decendsFromClass(Class child, Class parent) {
    Class nextParent = child;
    while(nextParent) {
        if (nextParent == parent) {
            return YES;
        }
        nextParent = class_getSuperclass(nextParent);
    }
    return NO;
}

Ivar class_getIvarForName(Class class, const char *name) {
    Ivar var = class_getInstanceVariable(class, name);
    if (var == NULL) {
        // It may be a property we have been passed so look for a '_' var.
        char * propertyName = NULL;
        asprintf(&propertyName, "%s%s", "_", name);
        var = class_getInstanceVariable(class, propertyName);
        if (var == NULL) {
            // Still null then it's may be a class variable.
            var = class_getClassVariable(class, name);
        }
    }
    return var;
}

