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

#import "ALCClassBuilder.h"
#import "ALCType.h"
#import <Alchemic/ALCContext.h>

@implementation ALCUIViewControllerInitWithCoderStrategy

+(BOOL) canWrapInit:(ALCClassBuilder *) instance {
    return [instance.valueType.typeClass isSubclassOfClass:[UIViewController class]];
}

-(SEL) replacementInitSelector {
    return @selector(initWithCoderReplacement:);
}

-(SEL) initSelector {
    return @selector(initWithCoder:);
}

-(id) initWithCoderReplacement:(NSCoder *) aDecoder {
    initLogic(init, initLogicArg(NSCoder *),  initLogicArg(aDecoder));
}

@end
