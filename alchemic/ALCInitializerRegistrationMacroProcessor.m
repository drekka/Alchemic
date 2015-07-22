//
//  ALCMacroArgumentProcessor.m
//  Alchemic
//
//  Created by Derek Clarkson on 15/07/2015.
//  Copyright © 2015 Derek Clarkson. All rights reserved.
//

@import ObjectiveC;

#import "ALCInitializerRegistrationMacroProcessor.h"
#import <Alchemic/Alchemic.h>

NS_ASSUME_NONNULL_BEGIN

@implementation ALCInitializerRegistrationMacroProcessor {
	NSMutableArray<ALCArg *> *_args;
}

-(instancetype) initWithParentClass:(Class) parentClass initializer:(SEL) initializer {
	self = [super initWithParentClass:parentClass];
	if (self) {
		_initializer = initializer;
		_args = [[NSMutableArray alloc] init];
	}
	return self;
}

-(void) addArgument:(id) argument {
	if ([argument isKindOfClass:[ALCArg class]]) {
		[_args addObject:argument];
	} else {
		[super addArgument:nil];
	}
}

-(NSArray<ALCArg *> *) methodValueSources {
	return _args;
}

-(void) validate {

	// Validate the selector and number of arguments.
	if (! class_respondsToSelector(self.parentClass, _initializer)) {
		@throw [NSException exceptionWithName:@"AlchemicSelectorNotFound"
												 reason:[NSString stringWithFormat:@"Failed to find initializer -[%s %s]", class_getName(self.parentClass), sel_getName(_initializer)]
											  userInfo:nil];
	}


	// Locate the method.
	Method method = class_getInstanceMethod(self.parentClass, _initializer);
	unsigned long nbrArgs = method_getNumberOfArguments(method) - 2;
	if (nbrArgs != [_args count]) {
		@throw [NSException exceptionWithName:@"AlchemicIncorrectNumberArguments"
												 reason:[NSString stringWithFormat:@"-[%s %s] - Expecting %lu argument matchers, got %lu",
															class_getName(self.parentClass),
															sel_getName(_initializer),
															nbrArgs,
															(unsigned long)[_args count]]
											  userInfo:nil];
	}

	[super validate];
}

@end

NS_ASSUME_NONNULL_END
