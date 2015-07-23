//
//  ALCClassInitializerBuilder.m
//  Alchemic
//
//  Created by Derek Clarkson on 22/07/2015.
//  Copyright © 2015 Derek Clarkson. All rights reserved.
//

#import <StoryTeller/StoryTeller.h>

#import "ALCInitializerMacroProcessor.h"
#import "ALCClassInitializerBuilder.h"

@implementation ALCClassInitializerBuilder

-(nonnull id) instantiateObject {
	id<ALCBuilder> parent = self.parentClassBuilder;
	STLog(self.valueClass, @"Instantiating a %@ using %@", NSStringFromClass(parent.valueClass), NSStringFromSelector(self.selector));
	id unInittedObj = [parent.valueClass alloc];
	return [self invokeMethodOn:unInittedObj];
}

@end
