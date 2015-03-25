//
//  ALCUIViewControllerInitialisationStrategy.m
//  alchemic
//
//  Created by Derek Clarkson on 27/02/2015.
//  Copyright (c) 2015 Derek Clarkson. All rights reserved.
//

@import UIKit;

#import "ALCUIViewControllerInitWithFrameStrategy.h"

#import <objc/runtime.h>
#import <objc/message.h>

#import "ALCLogger.h"
#import "Alchemic.h"
#import "ALCRuntimeFunctions.h"
#import "ALCContext.h"
#import "ALCInitDetails.h"

@implementation ALCUIViewControllerInitWithFrameStrategy

-(BOOL) canWrapInitInClass:(Class) class {
    return class_decendsFromClass(class, [UIViewController class]);
}

-(SEL) wrapperSelector {
    return @selector(initWithFrameWrapper:);
}

-(SEL) initSelector {
    return @selector(initWithFrame:);
}

-(id) initWithFrameWrapper:(CGRect) aFrame {
    
    Class selfClass = [self class];
    
    // Get the original init's IMP and call it or the default if no IMP has been stored (because there wasn't one).
    ALCInitDetails *initDetails = [ALCUIViewControllerInitWithFrameStrategy initDetailsForClass:selfClass initSelector:_cmd];
    
    if (initDetails.initIMP == NULL) {
        struct objc_super superData = {self, class_getSuperclass(selfClass)};
        self = ((id (*)(struct objc_super *, SEL, CGRect))objc_msgSendSuper)(&superData, @selector(initWithFrame:), aFrame);
    } else {
        self = ((id (*)(id, SEL, CGRect))initDetails.initIMP)(self, initDetails.initSelector, aFrame);
    }
    
    logRuntime(@"Triggering dependency injection in %s::initWithFrame:", class_getName(selfClass));
    //[[Alchemic mainContext] resolveDependencies:self];

    return self;
}

@end
