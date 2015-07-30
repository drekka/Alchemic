//
//
//  Created by Derek Clarkson on 9/05/2015.
//  Copyright (c) 2015 Derek Clarkson. All rights reserved.
//

#import <StoryTeller/StoryTeller.h>
@import ObjectiveC;
#import "ALCMacroProcessor.h"
#import "ALCMethodBuilder.h"

NS_ASSUME_NONNULL_BEGIN

@implementation ALCMethodBuilder

@synthesize valueClass = _valueClass;

-(instancetype) initWithParentClassBuilder:(ALCClassBuilder *) parentClassBuilder
											 selector:(SEL) selector {
	return nil;
}

-(instancetype) initWithParentBuilder:(ALCClassBuilder *) parentClassBuilder
									  selector:(nonnull SEL)selector
									valueClass:(Class) valueClass {
	self = [super initWithParentClassBuilder:parentClassBuilder
											  selector:selector];
	if (self) {
		_valueClass = valueClass;
		self.macroProcessor = [[ALCMacroProcessor alloc] initWithAllowedMacros:ALCAllowedMacrosArg + ALCAllowedMacrosFactory + ALCAllowedMacrosName + ALCAllowedMacrosPrimary];
	}
	return self;
}

-(void)configure {
	[super configure];
	NSString *name = self.macroProcessor.asName;
	self.name = name == nil ? [NSString stringWithFormat:@"%@::%@", NSStringFromClass(self.parentClassBuilder.valueClass), NSStringFromSelector(self.selector)] : name;
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
