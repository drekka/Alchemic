//
//
//  Created by Derek Clarkson on 9/05/2015.
//  Copyright (c) 2015 Derek Clarkson. All rights reserved.
//

#import <StoryTeller/StoryTeller.h>

#import "ALCMethodMacroProcessor.h"
#import "ALCMethodBuilder.h"

NS_ASSUME_NONNULL_BEGIN

@implementation ALCMethodBuilder

-(void)configureWithMacroProcessor:(nonnull id<ALCMacroProcessor>)macroProcessor {
	[super configureWithMacroProcessor:macroProcessor];
	ALCMethodMacroProcessor *processor = macroProcessor;
	self.factory = processor.isFactory;
	self.primary = processor.isPrimary;
	NSString *name = processor.asName;
	self.name = name == nil ? [NSString stringWithFormat:@"%@::%@", NSStringFromClass(self.valueClass), NSStringFromSelector(self.selector)] : name;

	self.createOnBoot = !self.factory;
}

-(nonnull id) instantiateObject {
	id<ALCBuilder> parent = self.parentClassBuilder;
	STLog(self.valueClass, @"Getting a %s parent object for method", class_getName(parent.valueClass));
	id factoryObject = parent.value;
	return [self invokeMethodOn:factoryObject];
}

@end

NS_ASSUME_NONNULL_END
