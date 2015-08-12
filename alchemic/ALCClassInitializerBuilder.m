//
//  ALCClassInitializerBuilder.m
//  Alchemic
//
//  Created by Derek Clarkson on 22/07/2015.
//  Copyright © 2015 Derek Clarkson. All rights reserved.
//

#import <StoryTeller/StoryTeller.h>

#import "ALCClassInitializerBuilder.h"
#import "ALCMacroProcessor.h"
#import "ALCClassBuilder.h"
@import ObjectiveC;

@implementation ALCClassInitializerBuilder

-(Class) valueClass {
	return self.parentClassBuilder.valueClass;
}

-(nonnull id) instantiateObject {
	ALCClassBuilder *parent = self.parentClassBuilder;
	id newObj = [self invokeMethodOn:[parent.valueClass alloc]];
	STLog(self, @"Instantiating a %@ using %@", NSStringFromClass(parent.valueClass), self);
	return newObj;
}

-(nonnull NSString *) description {
	return [NSString stringWithFormat:@"Initializer %@", [super description]];
}

@end
