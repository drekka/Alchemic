//
//  ALCMacroArgumentProcessorTests.m
//  Alchemic
//
//  Created by Derek Clarkson on 15/07/2015.
//  Copyright © 2015 Derek Clarkson. All rights reserved.
//
#import "ALCTestCase.h"

#import <Alchemic/Alchemic.h>

#import "ALCObjectFactoryMacroProcessor.h"
#import "ALCModelValueSource.h"
#import "ALCModelSearchExpression.h"
#import "ALCValueSource.h"
#import "ALCInternalMacros.h"

@interface ALCObjectFactoryMacroProcessorTests : ALCTestCase

@end

@implementation ALCObjectFactoryMacroProcessorTests {
    ALCObjectFactoryMacroProcessor *_processor;
}

-(void) setUp {
    _processor = [[ALCObjectFactoryMacroProcessor alloc] init];
}

-(void) testSetsIsFactoryFlag {
	[_processor addMacro:AcIsFactory];
    XCTAssertTrue(_processor.isFactory);
}

-(void) testSetsIsPrimaryFlag {
	[_processor addMacro:AcIsPrimary];
    XCTAssertTrue(_processor.isPrimary);
}

-(void) testSetsName {
	[_processor addMacro:AcWithName(@"abc")];
    XCTAssertEqualObjects(@"abc", _processor.asName);
}

-(void) testPassesMacroToParent {
	ALCArg *arg = AcArg(NSString, AcName(@"abc"));

	[_processor addMacro:arg];
	[_processor validate];

	XCTAssertEqual(arg, [_processor valueSourceFactoryForIndex:0]);
}

@end

