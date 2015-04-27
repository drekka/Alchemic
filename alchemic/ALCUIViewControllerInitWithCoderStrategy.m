//
//  ALCUIViewControllerInitWithCoderInitStrategy.m
//  alchemic
//
//  Created by Derek Clarkson on 27/02/2015.
//  Copyright (c) 2015 Derek Clarkson. All rights reserved.
//

#import "ALCUIViewControllerInitWithCoderStrategy.h"

@import UIKit;

@import ObjectiveC;


#import "Alchemic.h"
#import "ALCLogger.h"
#import "ALCRuntime.h"
#import "ALCContext.h"

@implementation ALCUIViewControllerInitWithCoderStrategy

+(BOOL) canWrapInit:(ALCInstance *) instance {
    return [ALCRuntime class:instance.forClass extends:[UIViewController class]];
}

-(SEL) replacementInitSelector {
    return @selector(initWithCoderReplacement:);
}

-(SEL) initSelector {
    return @selector(initWithCoder:);
}

-(id) initWithCoderReplacement:(NSCoder *) aDecoder {

    Class selfClass = object_getClass(self);
    SEL initSel = @selector(initWithCoder:);
    SEL relocatedInitSel = [ALCRuntime alchemicSelectorForSelector:initSel];
    
    // If the method exists then call it, otherwise call super.
    if ([self respondsToSelector:relocatedInitSel]) {
        self = ((id (*)(id, SEL, NSCoder *))objc_msgSend)(self, relocatedInitSel, aDecoder);
    } else {
        struct objc_super superData = {self, class_getSuperclass(selfClass)};
        self = ((id (*)(struct objc_super *, SEL, NSCoder *))objc_msgSendSuper)(&superData, initSel, aDecoder);
    }
    
    logRuntime(@"Triggering dependency injection from %s::%s", class_getName(selfClass), sel_getName(initSel));
    [[Alchemic mainContext] injectDependencies:self];

    return self;
}

@end
