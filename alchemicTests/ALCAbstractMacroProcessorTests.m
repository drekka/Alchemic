//
//  ALCAbstractMacroProcessorTests.m
//  Alchemic
//
//  Created by Derek Clarkson on 24/07/2015.
//  Copyright © 2015 Derek Clarkson. All rights reserved.
//

@import XCTest;

#import "ALCMacros.h"
#import "ALCAbstractMacroProcessor.h"
#import "ALCValueSourceFactory.h"
#import "ALCArg.h"
#import "ALCName.h"
#import "ALCConstantValue.h"
#import "ALCValueSource.h"
#import "ALCIsFactory.h"

@interface ALCAbstractMacroProcessorTests : XCTestCase

@end

@implementation ALCAbstractMacroProcessorTests {
	ALCAbstractMacroProcessor *_processor;
}

-(void) setUp {
	_processor = [[ALCAbstractMacroProcessor alloc] init];
}

-(void) testAddMacroArg {

	ALCArg *arg = AcArg(NSString, AcName(@"abc"));

	[_processor addMacro:arg];
	[_processor validate];

	XCTAssertEqual(arg, [_processor valueSourceFactoryForIndex:0]);
}

-(void) testAddMacroArgs {

	ALCArg *arg1 = AcArg(NSString, AcName(@"abc"));
	ALCArg *arg2 = AcArg(NSString, AcName(@"abc"));

	[_processor addMacro:arg1];
	[_processor addMacro:arg2];
	[_processor validate];

	XCTAssertEqual(arg1, [_processor valueSourceFactoryForIndex:0]);
	XCTAssertEqual(arg2, [_processor valueSourceFactoryForIndex:1]);
	XCTAssertEqual(2u, [_processor valueSourceCount]);
}

-(void) testAddMacroFirstExpression {

	ALCConstantValue *value = AcValue(@5);

	[_processor addMacro:value];
	[_processor validate];

	ALCValueSourceFactory *factory = [_processor valueSourceFactoryForIndex:0];
	XCTAssertEqualObjects(@5, [[factory valueSource] valueForType:[NSNumber class]]);

}

-(void) testAddMacroCombinesExpressions {

	ALCName *name1 = AcName(@"abc");
	ALCName *name2 = AcName(@"def");

	[_processor addMacro:name1];
	[_processor addMacro:name2];
	[_processor validate];

	ALCValueSourceFactory *factory = [_processor valueSourceFactoryForIndex:0];
	XCTAssertTrue([factory.macros containsObject:name1]);
	XCTAssertTrue([factory.macros containsObject:name2]);
}

-(void) testAddMacroWithInvalidCombinationOfMacros {

	id<ALCMacro, ALCValueDefMacro> name1 = AcName(@"abc");
	id<ALCMacro, ALCValueDefMacro> name2 = AcValue(@5);

	[_processor addMacro:name1];
	[_processor addMacro:name2];
	XCTAssertThrowsSpecificNamed([_processor validate], NSException, @"AlchemicInvalidArguments");

}

-(void) testAddMacroInvalidMacro {
	XCTAssertThrowsSpecificNamed([_processor addMacro:[[ALCIsFactory alloc] init]], NSException, @"AlchemicUnexpectedMacro");
}


@end
