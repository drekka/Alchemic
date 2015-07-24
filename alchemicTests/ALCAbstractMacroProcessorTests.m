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

	ALCArg *arg = ACArg(NSString, ACName(@"abc"));

	[_processor addMacro:arg];
	[_processor validate];

	XCTAssertEqual(arg, [_processor valueSourceFactoryForIndex:0]);
}

-(void) testAddMacroArgs {

	ALCArg *arg1 = ACArg(NSString, ACName(@"abc"));
	ALCArg *arg2 = ACArg(NSString, ACName(@"abc"));

	[_processor addMacro:arg1];
	[_processor addMacro:arg2];
	[_processor validate];

	XCTAssertEqual(arg1, [_processor valueSourceFactoryForIndex:0]);
	XCTAssertEqual(arg2, [_processor valueSourceFactoryForIndex:1]);
	XCTAssertEqual(2u, [_processor valueSourceCount]);
}

-(void) testAddMacroFirstExpression {

	ALCConstantValue *value = ACValue(@5);

	[_processor addMacro:value];
	[_processor validate];

	ALCValueSourceFactory *factory = [_processor valueSourceFactoryForIndex:0];
	XCTAssertEqualObjects(@5, [[factory valueSource] valueForType:[NSNumber class]]);

}

-(void) testAddMacroCombinesExpressions {

	ALCName *name1 = ACName(@"abc");
	ALCName *name2 = ACName(@"def");

	[_processor addMacro:name1];
	[_processor addMacro:name2];
	[_processor validate];

	ALCValueSourceFactory *factory = [_processor valueSourceFactoryForIndex:0];
	XCTAssertTrue([factory.macros containsObject:name1]);
	XCTAssertTrue([factory.macros containsObject:name2]);
}

-(void) testAddMacroWithInvalidCombinationOfMacros {

	id<ALCMacro, ALCValueDefMacro> name1 = ACName(@"abc");
	id<ALCMacro, ALCValueDefMacro> name2 = ACValue(@5);

	[_processor addMacro:name1];
	[_processor addMacro:name2];
	XCTAssertThrowsSpecificNamed([_processor validate], NSException, @"AlchemicInvalidArguments");

}

-(void) testAddMacroInvalidMacro {
	XCTAssertThrowsSpecificNamed([_processor addMacro:[[ALCIsFactory alloc] init]], NSException, @"AlchemicUnexpectedMacro");
}


@end
