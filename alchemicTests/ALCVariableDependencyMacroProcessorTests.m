//
//  ALCMacroArgumentProcessorTests.m
//  Alchemic
//
//  Created by Derek Clarkson on 15/07/2015.
//  Copyright © 2015 Derek Clarkson. All rights reserved.
//
@import XCTest;
@import ObjectiveC;

#import "ALCVariableDependencyMacroProcessor.h"
#import <Alchemic/Alchemic.h>
#import "ALCValueSource.h"

@interface ALCVariableDependencyMacroProcessorTests : XCTestCase
@end

@implementation ALCVariableDependencyMacroProcessorTests {
	ALCVariableDependencyMacroProcessor *_processor;
	NSString *_var;
	Ivar _varIvar;
}

-(void) setUp {
	_varIvar = class_getInstanceVariable([self class], "_var");
	_processor = [[ALCVariableDependencyMacroProcessor alloc] initWithVariable:_varIvar];
}

-(void) testInitWithVariable {
	XCTAssertEqual(_varIvar, _processor.variable);
}

-(void) testAddMacroRejectsValueSourceMacros {
	XCTAssertThrowsSpecificNamed(([_processor addMacro:AcArg(NSString, AcValue(@5))]), NSException, @"AlchemicUnexpectedMacro");
}

-(void) testAddMacroAcceptsExpressions {
	[_processor addMacro:AcName(@"abc")];
	[_processor validate];
	XCTAssertEqual(1u, [_processor valueSourceCount]);
}

-(void) testValidateCreatesIfNoMacrosPassed {
	[_processor validate];
	ALCValueSourceFactory *factory = [_processor valueSourceFactoryForIndex:0];
	XCTAssertTrue([factory.macros containsObject:AcClass(NSString)]);
}

@end

