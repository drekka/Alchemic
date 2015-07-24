//
//  ALCMacroArgumentProcessor.m
//  Alchemic
//
//  Created by Derek Clarkson on 15/07/2015.
//  Copyright © 2015 Derek Clarkson. All rights reserved.
//

@import ObjectiveC;

#import "ALCInitializerMacroProcessor.h"
#import "ALCMacro.h"
#import "ALCArg.h"

NS_ASSUME_NONNULL_BEGIN

@implementation ALCInitializerMacroProcessor

-(void) addMacro:(nonnull id<ALCMacro>)macro {
	// Error if we get anything except ALCArg macros.
	if (![macro isKindOfClass:[ALCArg class]]) {
		[self raiseUnexpectedMacroError:macro];
	} else {
		[super addMacro:macro];
	}
}

@end

NS_ASSUME_NONNULL_END
