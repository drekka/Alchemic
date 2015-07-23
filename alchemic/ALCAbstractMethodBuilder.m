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

NS_ASSUME_NONNULL_BEGIN

@implementation ALCAbstractMethodBuilder {
	NSInvocation *_inv;
	NSMutableArray<ALCDependency *> *_invArgumentDependencies;
	BOOL _useClassMethod;
}

-(instancetype) initWithValueClass:(__unsafe_unretained _Nonnull Class) valueClass {
	self = [super initWithValueClass:valueClass];
	if (self) {
		_invArgumentDependencies = [[NSMutableArray alloc] init];
	}
	return self;
}

-(void)configureWithMacroProcessor:(nonnull id<ALCMacroProcessor>) macroProcessor {
	[super configureWithMacroProcessor:macroProcessor];
	for (NSUInteger i = 0; i < [macroProcessor valueSourceCount]; i++) {
		ALCArg *arg = (ALCArg *)[macroProcessor valueSourceFactoryForIndex:i];
		[_invArgumentDependencies addObject:[[ALCDependency alloc] initWithValueClass:arg.argType
																								valueSource:[arg valueSource]]];
	}
	[self validateSelector:self.selector];
	[self validateArgumentsForSelector:self.selector macroProcessor:macroProcessor];
}

-(id) instantiateObject {
	[self doesNotRecognizeSelector:_cmd];
	return nil;
}

-(id) invokeMethodOn:(id) target {
	// Get an invocation ready.
	if (_inv == nil) {
		STLog(self.valueClass, @"Creating an invocation for %@", NSStringFromSelector(_selector));
		NSMethodSignature *sig = [_parentClassBuilder.valueClass instanceMethodSignatureForSelector:_selector];
		_inv = [NSInvocation invocationWithMethodSignature:sig];
		_inv.selector = _selector;
		[_inv retainArguments];
	}

	// Load the arguments.
	[_invArgumentDependencies enumerateObjectsUsingBlock:^(ALCDependency *dependency, NSUInteger idx, BOOL *stop) {
		id argumentValue = dependency.value;
		[self->_inv setArgument:&argumentValue atIndex:(NSInteger)idx];
	}];

	STLog(self.valueClass, @">>> Creating object with %@", [self description]);
	[_inv invokeWithTarget:target];

	id returnObj;
	[_inv getReturnValue:&returnObj];
	STLog(self.valueClass, @"Created a %s", class_getName([returnObj class]));
	return returnObj;
}

-(void) resolveDependenciesWithPostProcessors:(NSSet<id<ALCDependencyPostProcessor>> *) postProcessors {
	for(ALCDependency *dependency in _invArgumentDependencies) {
		[dependency resolveWithPostProcessors:postProcessors];
	};
}

-(void) injectObjectDependencies:(id _Nonnull) object {
	STLog([object class], @">>> Checking whether a %s instance has dependencies", object_getClassName(object));
	[[ALCAlchemic mainContext] injectDependencies:object];
}

-(nonnull NSString *) description {
	return [NSString stringWithFormat:@"Method builder -[%s %s] for type %s", class_getName(_parentClassBuilder.valueClass), sel_getName(_selector), class_getName(self.valueClass)];
}

@end

NS_ASSUME_NONNULL_END
