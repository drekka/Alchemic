//
//  ALCRuntimeFunctions.h
//  alchemic
//
//  Created by Derek Clarkson on 26/02/2015.
//  Copyright (c) 2015 Derek Clarkson. All rights reserved.
//

#import <objc/objc.h>
#import <Objc/runtime.h>

BOOL class_decendsFromClass(Class child, Class parent);

Ivar class_getIvarForName(Class class, const char *name);