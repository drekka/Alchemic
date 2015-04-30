//
//  ALCUIViewControllerInitStrategy.m
//  alchemic
//
//  Created by Derek Clarkson on 27/02/2015.
//  Copyright (c) 2015 Derek Clarkson. All rights reserved.
//

@import UIKit;

#import "ALCUIViewControllerInitWithFrameStrategy.h"

@import ObjectiveC;


#import "ALCLogger.h"
#import "Alchemic.h"
#import "ALCRuntime.h"
#import "ALCContext.h"

@implementation ALCUIViewControllerInitWithFrameStrategy

+(BOOL) canWrapInit:(ALCInstance *) instance {
    return [ALCRuntime class:instance.forClass extends:[UIViewController class]];
}

-(SEL) replacementInitSelector {
    return @selector(initWithFrameReplacement:);
}

-(SEL) initSelector {
    return @selector(initWithFrame:);
}

-(id) initWithFrameReplacement:(CGRect) aFrame {
    initLogic(init, initLogicArg(CGRect), initLogicArg(aFrame));
}

@end
