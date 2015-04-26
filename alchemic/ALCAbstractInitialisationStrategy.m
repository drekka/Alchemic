//
//  ALCAbstractInitialisationStrategy.m
//  alchemic
//
//  Created by Derek Clarkson on 27/02/2015.
//  Copyright (c) 2015 Derek Clarkson. All rights reserved.
//

#import "ALCAbstractInitialisationStrategy.h"

#import "ALCLogger.h"
#import "ALCInstance.h"
#import "ALCInternal.h"
#import "ALCRuntime.h"

#import <objc/runtime.h>


@implementation ALCAbstractInitialisationStrategy {
    Class _forClass;
}

@synthesize initSelector;
@synthesize initWrapperSelector;

// Abstract
+(BOOL) canWrapInit:(ALCInstance *) instance {
    return NO;
}

-(instancetype) initWithInstance:(ALCInstance *)instance {
    self = [super init];
    if (self) {
        _forClass = instance.forClass;
        [self wrapInit];
    }
    return self;
}

-(void) wrapInit {
    
    // Get the new imp.
    SEL wrapperSel = self.initWrapperSelector;
    SEL initSel = self.initSelector;
    
    Class selfClass = object_getClass(self);
    Method wrapperMethod = class_getInstanceMethod(selfClass, wrapperSel);
    const char * initTypeEncoding = method_getTypeEncoding(wrapperMethod);
    IMP wrapperIMP = class_getMethodImplementation(selfClass, wrapperSel);
    
    // First attempt to add a new init.
    if (class_addMethod(_forClass, initSel, wrapperIMP, initTypeEncoding)) {
        logRuntime(@"Added %s::%s", class_getName(_forClass), sel_getName(initSel));
        return;
    }
    
    // There must already be an init, so now we replace it.
    logRuntime(@"Wrapping %s::%s", class_getName(_forClass), sel_getName(initSel));
    Method initMethod = class_getInstanceMethod(_forClass, initSel);
    IMP originalInit = method_setImplementation(initMethod, wrapperIMP);
    
    // Add the original init back into the class using a prefix.
    SEL alchemicInitSel = [ALCRuntime alchemicSelectorForSelector:initSel];
    class_addMethod(_forClass, alchemicInitSel, originalInit, initTypeEncoding);
    
}

-(void) resetInit {
    SEL initSel = self.initSelector;
    SEL alchemicInitSel = [ALCRuntime alchemicSelectorForSelector:initSel];
    logRuntime(@"Resetting %s::%s", class_getName(_forClass), sel_getName(initSel));
    Method initMethod = class_getInstanceMethod(_forClass, initSel);
    IMP originalIMP = class_getMethodImplementation(_forClass, alchemicInitSel);
    method_setImplementation(initMethod, originalIMP);
}

@end
