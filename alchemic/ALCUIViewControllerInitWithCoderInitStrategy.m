//
//  ALCUIViewControllerInitWithCoderInitStrategy.m
//  alchemic
//
//  Created by Derek Clarkson on 27/02/2015.
//  Copyright (c) 2015 Derek Clarkson. All rights reserved.
//

#import "ALCUIViewControllerInitWithCoderInitStrategy.h"

@import UIKit;
@import Foundation;
#import <objc/runtime.h>
#import <objc/message.h>
#import "ALCLogger.h"
#import "ALCRuntimeFunctions.h"
#import "ALCContext.h"
#import "ALCOriginalInitInfo.h"

@implementation ALCUIViewControllerInitWithCoderInitStrategy

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

    // Get the original init's IMP and call it or the default if no IMP has been stored (because there wasn't one).
    ALCOriginalInitInfo *initInfo = [ALCUIViewControllerInitWithCoderInitStrategy initInfoForClass:[self class] initSelector:_cmd];
    
    if (initInfo.initIMP == NULL) {
        struct objc_super superData = {self, class_getSuperclass([self class])};
        self = ((id (*)(struct objc_super *, SEL, NSCoder *))objc_msgSendSuper)(&superData, @selector(initWithCoder:), aDecoder);
    } else {
        self = ((id (*)(id, SEL, NSCoder *))initInfo.initIMP)(self, initInfo.initSelector, aDecoder);
    }
    
    logCreation(@"Triggering dependency injection in initWithCoder:");
    [initInfo.context resolveDependencies:self];

    return self;
}

@end
