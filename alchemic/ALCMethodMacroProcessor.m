//
//  ALCMacroArgumentProcessor.m
//  Alchemic
//
//  Created by Derek Clarkson on 15/07/2015.
//  Copyright © 2015 Derek Clarkson. All rights reserved.
//

@import ObjectiveC;

#import "ALCMethodMacroProcessor.h"
#import "ALCValueDefMacro.h"
#import "ALCMacro.h"

NS_ASSUME_NONNULL_BEGIN

@implementation ALCMethodMacroProcessor

-(void) addMacro:(nonnull id<ALCMacro>)macro {
	// Error if we get expressions
	if ([macro conformsToProtocol:@protocol(ALCValueDefMacro)]) {
		[self raiseUnexpectedMacroError:macro];
	} else {
		[super addMacro:macro];
	}
}

@end

NS_ASSUME_NONNULL_END
