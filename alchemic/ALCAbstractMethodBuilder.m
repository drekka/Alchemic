//
//
//  Created by Derek Clarkson on 9/05/2015.
//  Copyright (c) 2015 Derek Clarkson. All rights reserved.
//

#import <StoryTeller/StoryTeller.h>

#import "ALCAbstractMethodBuilder.h"
#import "ALCRuntime.h"
#import "ALCClassBuilder.h"
#import "ALCMacroProcessor.h"
#import "ALCDependency.h"
#import "ALCArg.h"
#import "ALCAlchemic.h"
#import "ALCContext.h"
#import "ALCSearchableBuilder.h"
#import "ALCInternalMacros.h"

NS_ASSUME_NONNULL_BEGIN

@implementation ALCAbstractMethodBuilder {
	BOOL _useClassMethod;
}

-(instancetype) init {
	return nil;
}

-(instancetype) initWithParentClassBuilder:(ALCClassBuilder *) parentClassBuilder
											 selector:(SEL) selector {
	self = [super init];
	if (self) {
		_parentClassBuilder = parentClassBuilder;
		_selector = selector;
	}
	return self;
}

-(void)configure {
	[super configure];
	for (NSUInteger i = 0; i < [self.macroProcessor valueSourceCount]; i++) {
		ALCArg *arg = (ALCArg *)[self.macroProcessor valueSourceFactoryAtIndex:i];
		[self.dependencies addObject:[[ALCDependency alloc] initWithValueClass:arg.argType
																					  valueSource:[arg valueSource]]];
	}
	[self validateClass:self.parentClassBuilder.valueClass
				  selector:self.selector
		  macroProcessor:self.macroProcessor];
}

-(id) instantiateObject {
	[self doesNotRecognizeSelector:_cmd];
	return nil;
}

-(id) invokeMethodOn:(id) target {
	// Get an invocation ready.
	if (_inv == nil) {
		STLog(ALCHEMIC_LOG, @"Creating an invocation for %@", NSStringFromSelector(_selector));
		NSMethodSignature *sig = [[target class] instanceMethodSignatureForSelector:_selector];
		_inv = [NSInvocation invocationWithMethodSignature:sig];
		_inv.selector = _selector;
		[_inv retainArguments];
	}

	// Load the arguments.
	[self.dependencies enumerateObjectsUsingBlock:^(ALCDependency *dependency, NSUInteger idx, BOOL *stop) {
		id argumentValue = dependency.value;
		[self->_inv setArgument:&argumentValue atIndex:(NSInteger) idx + 2];
	}];

	STLog(ALCHEMIC_LOG, @"Creating object with %@", [self description]);
	[_inv invokeWithTarget:target];

	id __unsafe_unretained returnObj;
	[_inv getReturnValue:&returnObj];
	STLog(ALCHEMIC_LOG, @"Created a %s", class_getName([returnObj class]));
	return returnObj;
}

@end

NS_ASSUME_NONNULL_END
