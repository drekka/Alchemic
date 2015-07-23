//
//  ALCClassRegistrationMacroProcessor.m
//  Alchemic
//
//  Created by Derek Clarkson on 23/07/2015.
//  Copyright © 2015 Derek Clarkson. All rights reserved.
//

#import "ALCClassRegistrationMacroProcessor.h"
#import "ALCValueSourceFactory.h"
#import "ALCValueDefMacro.h"
#import "ALCMacro.h"

@implementation ALCClassRegistrationMacroProcessor

-(void)addMacro:(nonnull id<ALCMacro>)macro {
	// Error if we get value source arguments.
	if ([macro isKindOfClass:[ALCValueSourceFactory class]] || [macro conformsToProtocol:@protocol(ALCValueDefMacro)]) {
		[self raiseUnexpectedMacroError:macro];
	} else {
		[super addMacro:macro];
	}
}


@end
