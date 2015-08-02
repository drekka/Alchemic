//
//
//  Created by Derek Clarkson on 9/05/2015.
//  Copyright (c) 2015 Derek Clarkson. All rights reserved.
//

#import <StoryTeller/StoryTeller.h>
@import ObjectiveC;
#import "ALCMacroProcessor.h"
#import "ALCMethodBuilder.h"
#import "ALCAlchemic.h"
#import "ALCContext.h"

NS_ASSUME_NONNULL_BEGIN

@implementation ALCMethodBuilder

@synthesize valueClass = _valueClass;

-(instancetype) initWithParentClassBuilder:(ALCClassBuilder *) parentClassBuilder
											 selector:(SEL) selector {
	return nil;
}

-(instancetype) initWithParentBuilder:(ALCClassBuilder *) parentClassBuilder
									  selector:(SEL)selector
									valueClass:(Class) valueClass {
	self = [super initWithParentClassBuilder:parentClassBuilder
											  selector:selector];
	if (self) {
		_valueClass = valueClass;
		self.macroProcessor = [[ALCMacroProcessor alloc] initWithAllowedMacros:ALCAllowedMacrosArg + ALCAllowedMacrosFactory + ALCAllowedMacrosName + ALCAllowedMacrosPrimary];
		self.name = [NSString stringWithFormat:@"%@::%@", NSStringFromClass(self.parentClassBuilder.valueClass), NSStringFromSelector(self.selector)];
	}
	return self;
}

-(void)configure {
	[super configure];
	NSString *name = self.macroProcessor.asName;
	if (name != nil) {
		self.name = name;
	}
}

-(id) instantiateObject {
	id<ALCBuilder> parent = self.parentClassBuilder;
	STLog(self.valueClass, @"Retrieving method's parent object ...");
	id factoryObject = parent.value;
	return [self invokeMethodOn:factoryObject];
}

-(NSString *) description {
	return [NSString stringWithFormat:@"Method builder -(%2$@ *) [%1$s %3$s]", class_getName(self.parentClassBuilder.valueClass), NSStringFromClass(self.valueClass), sel_getName(self.selector)];
}

-(void) injectValueDependencies:(id) value {
	STLog([value class], @"Handing a %s instance to the context for dependency injection", object_getClassName(value));
	[[ALCAlchemic mainContext] injectDependencies:value];
}


@end

NS_ASSUME_NONNULL_END
