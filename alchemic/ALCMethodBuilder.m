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

@synthesize valueClass = _valueClass;

-(instancetype) initWithSelector:(nonnull SEL)selector {
	return nil;
}

-(instancetype) initWithSelector:(nonnull SEL)selector valueClass:(nonnull Class)valueClass {
	self = [super initWithSelector:selector];
	if (self) {
		_valueClass = valueClass;
	}
	return self;
}

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
	id factoryObject = parent.value;
	return [self invokeMethodOn:factoryObject];
}

-(nonnull NSString *) description {
	return [NSString stringWithFormat:@"Method builder [%s -(%@ *) %s]", class_getName(self.parentClassBuilder.valueClass), NSStringFromClass(self.valueClass), sel_getName(self.selector)];
}

@end

NS_ASSUME_NONNULL_END
