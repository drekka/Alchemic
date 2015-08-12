//
//  ALCTestCase.m
//  alchemic
//
//  Created by Derek Clarkson on 23/02/2015.
//  Copyright (c) 2015 Derek Clarkson. All rights reserved.
//

#import <OCMock/OCMock.h>
#import <StoryTeller/StoryTeller.h>
@import ObjectiveC;

#import "ALCTestCase.h"
#import "ALCPrimaryObjectDependencyPostProcessor.h"
#import "ALCRuntime.h"
#import "ALCRuntimeScanner.h"
#import "ALCMacroProcessor.h"
#import "ALCInternalMacros.h"

NS_ASSUME_NONNULL_BEGIN

@interface ALCAlchemic (hack)
+(void) unload;
@end

@implementation ALCTestCase {
	id _mockAlchemic;
}

+(void)initialize {
	[STStoryTeller storyTeller].logger.lineTemplate = [NSString stringWithFormat:@"%4$@ %1$@ %2$@:%3$@", STLoggerTemplateKeyMessage, STLoggerTemplateKeyFunction, STLoggerTemplateKeyLine, STLoggerTemplateKeyKey];
}

-(void) tearDown {
	// Stop the mocking.
	_mockAlchemic = nil;
	_mockContext = nil;

	// Clear Alchemic's singleton reference.
	[ALCAlchemic unload];

	// Reset logging.
	[[STStoryTeller storyTeller] reset];
}

-(void)setupMockContext {
	NSAssert(_context == nil, @"Cannot setup both a real and mock context");
	_mockContext = OCMClassMock([ALCContext class]);
	_mockAlchemic = OCMClassMock([ALCAlchemic class]);
	OCMStub(ClassMethod([_mockAlchemic mainContext])).andReturn(_mockContext);
}

-(void)setupRealContext {
	NSAssert(_mockContext == nil, @"Cannot setup both a real and mock context");
	_context = [[ALCContext alloc] init];
	_mockAlchemic = OCMClassMock([ALCAlchemic class]);
	OCMStub(ClassMethod([_mockAlchemic mainContext])).andReturn(_context);
}

-(void) startContextWithClasses:(NSArray<Class> *) classes {
	NSAssert(_context != nil, @"[ALCTestCase setupRealContext must be called first.");
	NSSet<ALCRuntimeScanner *> *scanners = [NSSet setWithArray:@[
																					 [ALCRuntimeScanner dependencyPostProcessorScanner],
																					 [ALCRuntimeScanner resourceLocatorScanner]
																					 ]];
	[ALCRuntime scanRuntimeWithContext:_context runtimeScanners:scanners];

	ALCRuntimeScanner *modelScanner = [ALCRuntimeScanner modelScanner];
	[classes enumerateObjectsUsingBlock:^(Class  _Nonnull aClass, NSUInteger idx, BOOL * _Nonnull stop) {
		modelScanner.processor(self.context, aClass);
	}];

	[_context start];

}

@end

NS_ASSUME_NONNULL_END