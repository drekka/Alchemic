//
//  ALCClassInitializerBuilder.m
//  Alchemic
//
//  Created by Derek Clarkson on 22/07/2015.
//  Copyright © 2015 Derek Clarkson. All rights reserved.
//

#import <Alchemic/Alchemic.h>
#import <StoryTeller/StoryTeller.h>

#import "ALCClassInitializerBuilder.h"

@implementation ALCClassInitializerBuilder

-(nonnull id) instantiateObject {
	STLog(self.valueClass, @"Instantiating a %s using %s", class_getName(self.parentClassBuilder.valueClass), sel_getName(self.selector));
	id unInittedObj = [self.parentClassBuilder.valueClass alloc];
	return [self invokeMethodOn:unInittedObj];
}

@end
