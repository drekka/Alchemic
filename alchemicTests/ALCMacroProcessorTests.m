//
//  ALCAbstractMacroProcessorTests.m
//  Alchemic
//
//  Created by Derek Clarkson on 24/07/2015.
//  Copyright © 2015 Derek Clarkson. All rights reserved.
//

@import XCTest;

#import "ALCMacros.h"
#import "ALCMacroProcessor.h"
#import "ALCValueSourceFactory.h"
#import "ALCArg.h"
#import "ALCName.h"
#import "ALCConstantValue.h"
#import "ALCValueSource.h"
#import "ALCIsFactory.h"

@interface ALCMacroProcessorTests : XCTestCase

@end

@implementation ALCMacroProcessorTests {
	ALCMacroProcessor *_processor;
}

-(void) setUp {
	_processor = [[ALCMacroProcessor alloc] initWithAllowedMacros:
					  ALCAllowedMacrosArg
					  + ALCAllowedMacrosValueDef
					  + ALCAllowedMacrosFactory
					  + ALCAllowedMacrosName
					  + ALCAllowedMacrosPrimary];
}

-(void) testAddMacroFactory {
	[_processor addMacro:AcIsFactory];
	XCTAssertTrue(_processor.isFactory);
}

-(void) testAddMacroPrimary {
	[_processor addMacro:AcIsPrimary];
	XCTAssertTrue(_processor.isPrimary);
}

-(void) testAddMacroName {
	[_processor addMacro:AcWithName(@"abc")];
	XCTAssertEqualObjects(@"abc", _processor.asName);
}

-(void) testAddMacroArg {
	ALCArg *arg = AcArg(NSString, AcName(@"abc"));
	[_processor addMacro:arg];
	XCTAssertEqual(arg, [_processor valueSourceFactoryAtIndex:0]);
}

-(void) testAddMacroArgs {

	ALCArg *arg1 = AcArg(NSString, AcName(@"abc"));
	ALCArg *arg2 = AcArg(NSString, AcName(@"abc"));

	[_processor addMacro:arg1];
	[_processor addMacro:arg2];

	XCTAssertEqual(arg1, [_processor valueSourceFactoryAtIndex:0]);
	XCTAssertEqual(arg2, [_processor valueSourceFactoryAtIndex:1]);
	XCTAssertEqual(2u, [_processor valueSourceCount]);
}

-(void) testAddMacroFirstExpression {

	ALCConstantValue *value = AcValue(@5);

	[_processor addMacro:value];

	ALCValueSourceFactory *factory = [_processor valueSourceFactoryAtIndex:0];
	XCTAssertEqualObjects(@5, [[factory valueSource] valueForType:[NSNumber class]]);

}

-(void) testAddMacroCombinesExpressions {

	ALCName *name1 = AcName(@"abc");
	ALCName *name2 = AcName(@"def");

	[_processor addMacro:name1];
	[_processor addMacro:name2];

	ALCValueSourceFactory *factory = [_processor valueSourceFactoryAtIndex:0];
	XCTAssertTrue([factory.macros containsObject:name1]);
	XCTAssertTrue([factory.macros containsObject:name2]);
}

-(void) testAddMacroInvalidMacro {
	ALCMacroProcessor *processor = [[ALCMacroProcessor alloc] initWithAllowedMacros:0];
	XCTAssertThrowsSpecificNamed([processor addMacro:[[ALCIsFactory alloc] init]], NSException, @"AlchemicUnexpectedMacro");
}


@end
