//
//  ALCClassMacroProcessor.m
//  Alchemic
//
//  Created by Derek Clarkson on 17/07/2015.
//  Copyright © 2015 Derek Clarkson. All rights reserved.
//


@import ObjectiveC;

#import "ALCObjectFactoryMacroProcessor.h"
#import "ALCIsFactory.h"
#import "ALCWithName.h"
#import "ALCIsPrimary.h"

NS_ASSUME_NONNULL_BEGIN

@implementation ALCObjectFactoryMacroProcessor

-(void) addMacro:(id<ALCMacro>)macro {

    if ([macro isKindOfClass:[ALCIsFactory class]]) {
        _isFactory = YES;
    } else if ([macro isKindOfClass:[ALCWithName class]]) {
        _asName = ((ALCWithName *)macro).asName;
    } else if ([macro isKindOfClass:[ALCIsPrimary class]]) {
        _isPrimary = YES;
    } else {
		 [super addMacro:macro];
    }
}

@end

NS_ASSUME_NONNULL_END

