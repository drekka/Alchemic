//
//  ALCClassMacroProcessor.m
//  Alchemic
//
//  Created by Derek Clarkson on 17/07/2015.
//  Copyright © 2015 Derek Clarkson. All rights reserved.
//


@import ObjectiveC;

#import "ALCClassRegistrationMacroProcessor.h"
#import <Alchemic/Alchemic.h>

NS_ASSUME_NONNULL_BEGIN

@implementation ALCClassRegistrationMacroProcessor

-(void) addArgument:(id) argument {

    if ([argument isKindOfClass:[ALCIsFactory class]]) {
        _isFactory = YES;
    } else if ([argument isKindOfClass:[ALCWithName class]]) {
        _asName = ((ALCWithName *)argument).asName;
    } else if ([argument isKindOfClass:[ALCIsPrimary class]]) {
        _isPrimary = YES;
    } else {
        [super addArgument:argument];
    }
}

-(void) validate {
    // Setup the name.
    if (_asName == nil) {
        _asName = NSStringFromClass(self.parentClass);
    }
}

@end

NS_ASSUME_NONNULL_END

