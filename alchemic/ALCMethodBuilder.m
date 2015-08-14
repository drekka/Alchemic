//
//
//  Created by Derek Clarkson on 9/05/2015.
//  Copyright (c) 2015 Derek Clarkson. All rights reserved.
//

#import <StoryTeller/StoryTeller.h>
@import ObjectiveC;
#import "ALCMacroProcessor.h"
#import "ALCMethodBuilder.h"
#import "ALCClassBuilder.h"
#import "ALCAlchemic.h"
#import "ALCContext.h"

NS_ASSUME_NONNULL_BEGIN

@implementation ALCMethodBuilder

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
		self.valueClass = valueClass;
	}
	return self;
}

-(id) instantiateObject {
	ALCClassBuilder *parent = self.parentClassBuilder;
	STLog(self.valueClass, @"Retrieving method's parent object ...");
	id factoryObject = parent.value;
	return [self invokeMethodOn:factoryObject];
}

-(NSString *) description {
	return [NSString stringWithFormat:@"%@'%@' Method builder -(%@ *) %@%@", [self stateDescription], self.name, NSStringFromClass(self.valueClass), [super description], self.attributesDescription];
}

-(void) injectValueDependencies:(id) value {
	STLog([value class], @"Handing a %s instance to the context for dependency injection", object_getClassName(value));
	[[ALCAlchemic mainContext] injectDependencies:value];
}


@end

NS_ASSUME_NONNULL_END
