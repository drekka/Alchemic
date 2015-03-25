//
//  ALCUIViewControllerInitWithCoderInitStrategy.m
//  alchemic
//
//  Created by Derek Clarkson on 27/02/2015.
//  Copyright (c) 2015 Derek Clarkson. All rights reserved.
//

#import "ALCUIViewControllerInitWithCoderStrategy.h"

@import UIKit;
@import Foundation;

#import <objc/runtime.h>
#import <objc/message.h>

#import "Alchemic.h"
#import "ALCLogger.h"
#import "ALCRuntimeFunctions.h"
#import "ALCContext.h"
#import "ALCInitDetails.h"

@implementation ALCUIViewControllerInitWithCoderStrategy

-(BOOL) canWrapInitInClass:(Class) class {
    return class_decendsFromClass(class, [UIViewController class]);
}

-(SEL) wrapperSelector {
    return @selector(initWithCoderWrapper:);
}

-(SEL) initSelector {
    return @selector(initWithCoder:);
}

-(id) initWithCoderWrapper:(NSCoder *) aDecoder {

    Class selfClass = [self class];
    // Get the original init's IMP and call it or the default if no IMP has been stored (because there wasn't one).
    ALCInitDetails *initDetails = [ALCUIViewControllerInitWithCoderStrategy initDetailsForClass:selfClass initSelector:_cmd];
    
    if (initDetails.initIMP == NULL) {
        struct objc_super superData = {self, class_getSuperclass(selfClass)};
        self = ((id (*)(struct objc_super *, SEL, NSCoder *))objc_msgSendSuper)(&superData, @selector(initWithCoder:), aDecoder);
    } else {
        self = ((id (*)(id, SEL, NSCoder *))initDetails.initIMP)(self, initDetails.initSelector, aDecoder);
    }
    
    logRuntime(@"Triggering dependency injection in %s::initWithCoder:", class_getName(selfClass));
    //[[Alchemic mainContext] resolveDependencies:self];

    return self;
}

@end
