//
//  ALCMacroArgumentProcessorTests.m
//  Alchemic
//
//  Created by Derek Clarkson on 15/07/2015.
//  Copyright © 2015 Derek Clarkson. All rights reserved.
//

#import "ALCTestCase.h"

#import "ALCVariableDependencyMacroProcessor.h"
#import <Alchemic/Alchemic.h>
#import "ALCModelValueSource.h"

@interface ALCVariableDependencyMacroProcessorTests : ALCTestCase
@end

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wundeclared-selector"

@implementation ALCVariableDependencyMacroProcessorTests {
	ALCVariableDependencyMacroProcessor *_processor;
	ALCName *_stringQ;
	ALCClass *_classQ;
	ALCProtocol *_protocolQ;

	NSString *_stringVar;
}

-(void) setUp {
	_stringQ = [ALCName withName:@"abc"];
	_classQ = [ALCClass withClass:[self class]];
	_protocolQ = [ALCProtocol withProtocol:@protocol(NSCopying)];
	Ivar var = class_getInstanceVariable([self class], "_stringVar");
	_processor = [[ALCVariableDependencyMacroProcessor alloc] initWithVariable:var];
}

-(void) testDependencyWithConstantValue {
	[self loadMacroProcessor:_processor withArguments:ACValue(@12), nil];
	id<ALCValueSource> valueSource = [[_processor valueSourceFactoryForIndex:0] valueSource];
	XCTAssertEqualObjects(@12, valueSource.values.anyObject);
}

-(void) testDependencyWithConstantAndOtherMacrosThrows {
	XCTAssertThrowsSpecificNamed(([self loadMacroProcessor:_processor withArguments:ACValue(@12), ACClass([self class]), nil]), NSException, @"AlchemicInvalidArguments");
}

-(void) testDependencyWithModelValueSource {
	[self loadMacroProcessor:_processor withArguments:_stringQ, _classQ, _protocolQ, nil];
	ALCModelValueSource *valueSource = [[_processor valueSourceFactoryForIndex:0] valueSource];
	NSSet<id<ALCModelSearchExpression>> *searchExpressions = valueSource.searchExpressions;
	XCTAssertTrue([searchExpressions containsObject:_stringQ]);
	XCTAssertTrue([searchExpressions containsObject:_classQ]);
	XCTAssertTrue([searchExpressions containsObject:_protocolQ]);
}

-(void) testDependencyWithArrayArgumentThrows {
	XCTAssertThrowsSpecificNamed(([self loadMacroProcessor:_processor withArguments:_stringQ, @[_classQ, _protocolQ], nil]), NSException, @"AlchemicUnexpectedMacro");
}

@end

#pragma clang diagnostic pop
