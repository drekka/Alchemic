//
//  ALCSimpleInitWrapper.m
//  alchemic
//
//  Created by Derek Clarkson on 26/02/2015.
//  Copyright (c) 2015 Derek Clarkson. All rights reserved.
//

#import "ALCNSObjectInitStrategy.h"

@import UIKit;

#import <objc/runtime.h>
#import <objc/message.h>

#import "ALCLogger.h"
#import "ALCRuntime.h"
#import "ALCContext.h"
#import "Alchemic.h"

@implementation ALCNSObjectInitStrategy

-(BOOL) canWrapInit:(ALCInstance *) instance {
    return ! [ALCRuntime class:instance.forClass extends:[UIViewController class]];
}

-(SEL) initWrapperSelector {
    return @selector(initWrapper);
}

-(SEL) initSelector {
    return @selector(init);
}

-(id) initWrapper {

    // Get the selector for the original init which will now have an alchemic prefix.
    Class selfClass = object_getClass(self);
    SEL initSel = @selector(init);
    SEL relocatedInitSel = [ALCRuntime alchemicSelectorForSelector:initSel];
    
    // If the method exists then call it, otherwise call super.
    if ([self respondsToSelector:relocatedInitSel]) {
        self = ((id (*)(id, SEL))objc_msgSend)(self, relocatedInitSel);
    } else {
        struct objc_super superData = {self, class_getSuperclass(selfClass)};
        self = ((id (*)(struct objc_super *, SEL))objc_msgSendSuper)(&superData, initSel);
    }
    
    logRuntime(@"Triggering dependency injection from %s::%s", class_getName(selfClass), sel_getName(initSel));
    [[Alchemic mainContext] injectDependencies:self];
    
    return self;
}

@end
