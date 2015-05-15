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

#import "ALCRuntime.h"
#import "ALCLogger.h"
#import "Alchemic.h"
#import "ALCContext.h"
#import "ALCObjectInstance.h"

@implementation ALCUIViewControllerInitWithFrameStrategy

+(BOOL) canWrapInit:(ALCObjectInstance *) instance {
    return [instance.objectClass isSubclassOfClass:[UIViewController class]];
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
