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
#import "ALCSearchableBuilder.h"

@implementation ALCClassInitializerBuilder

-(nonnull id) instantiateObject {
	id<ALCSearchableBuilder> parent = self.parentClassBuilder;
	id unInittedObj = [parent.valueClass alloc];
	id newObj = [self invokeMethodOn:unInittedObj];
	STLog(self, @"Instantiating a %@ using %@", NSStringFromClass(parent.valueClass), NSStringFromSelector(self.selector));
	return newObj;
}

-(nonnull NSString *) description {
	return [NSString stringWithFormat:@"Initializer -[%@ %@]", NSStringFromClass(self.parentClassBuilder.valueClass), NSStringFromSelector(self.selector)];
}

@end
