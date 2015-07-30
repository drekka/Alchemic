//
//  ALCClassInitializerBuilder.m
//  Alchemic
//
//  Created by Derek Clarkson on 22/07/2015.
//  Copyright © 2015 Derek Clarkson. All rights reserved.
//

#import <StoryTeller/StoryTeller.h>

#import "ALCClassInitializerBuilder.h"
#import "ALCSearchableBuilder.h"
#import "ALCMacroProcessor.h"
@import ObjectiveC;

@implementation ALCClassInitializerBuilder

-(instancetype) initWithParentClassBuilder:(ALCClassBuilder *) parentClassBuilder
											 selector:(SEL) selector {
	self = [super initWithParentClassBuilder:parentClassBuilder selector:selector];
	if (self) {
		self.macroProcessor = [[ALCMacroProcessor alloc] initWithAllowedMacros:ALCAllowedMacrosArg];
	}
	return self;
}

-(nonnull id) instantiate {
	id<ALCSearchableBuilder> parent = self.parentClassBuilder;
	id newObj = [self invokeMethodOn:[parent.valueClass alloc]];
	STLog(self, @"Instantiating a %@ using %@", NSStringFromClass(parent.valueClass), NSStringFromSelector(self.selector));
	return newObj;
}

-(nonnull NSString *) description {
	return [NSString stringWithFormat:@"Initializer -[%@ %@]", NSStringFromClass(self.parentClassBuilder.valueClass), NSStringFromSelector(self.selector)];
}

@end
