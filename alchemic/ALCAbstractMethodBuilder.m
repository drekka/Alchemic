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

NS_ASSUME_NONNULL_BEGIN

@implementation ALCAbstractMethodBuilder {
	BOOL _useClassMethod;
}

-(instancetype) init {
	return nil;
}

-(nonnull instancetype)initWithSelector:(nonnull SEL)selector {
	self = [super init];
	if (self) {
		_selector = selector;
	}
	return self;
}

-(void)configureWithMacroProcessor:(nonnull id<ALCMacroProcessor>) macroProcessor {
	[super configureWithMacroProcessor:macroProcessor];
	for (NSUInteger i = 0; i < [macroProcessor valueSourceCount]; i++) {
		ALCArg *arg = (ALCArg *)[macroProcessor valueSourceFactoryForIndex:i];
		[self.dependencies addObject:[[ALCDependency alloc] initWithValueClass:arg.argType
																					  valueSource:[arg valueSource]]];
	}
	[self validateClass:self.parentClassBuilder.valueClass
				  selector:self.selector
		  macroProcessor:macroProcessor];
}

-(id) instantiateObject {
	[self doesNotRecognizeSelector:_cmd];
	return nil;
}

-(id) invokeMethodOn:(id) target {
	// Get an invocation ready.
	if (_inv == nil) {
		STLog(self, @"Creating an invocation for %@", NSStringFromSelector(_selector));
		NSMethodSignature *sig = [[target class] instanceMethodSignatureForSelector:_selector];
		_inv = [NSInvocation invocationWithMethodSignature:sig];
		_inv.selector = _selector;
		[_inv retainArguments];
	}

	// Load the arguments.
	[self.dependencies enumerateObjectsUsingBlock:^(ALCDependency *dependency, NSUInteger idx, BOOL *stop) {
		id argumentValue = dependency.value;
		[self->_inv setArgument:&argumentValue atIndex:(NSInteger)idx];
	}];

	STLog(self, @">>> Creating object with %@", [self description]);
	[_inv invokeWithTarget:target];

	id returnObj;
	[_inv getReturnValue:&returnObj];
	STLog(self, @"Created a %s", class_getName([returnObj class]));
	return returnObj;
}

@end

NS_ASSUME_NONNULL_END
