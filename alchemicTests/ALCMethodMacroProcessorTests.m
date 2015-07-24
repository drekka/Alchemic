//
//  ALCMacroArgumentProcessorTests.m
//  Alchemic
//
//  Created by Derek Clarkson on 15/07/2015.
//  Copyright © 2015 Derek Clarkson. All rights reserved.
//

@import XCTest;

#import <Alchemic/Alchemic.h>

#import "ALCMethodMacroProcessor.h"
#import "ALCValueSource.h"

@interface ALCMethodMacroProcessorTests : XCTestCase

@end

@implementation ALCMethodMacroProcessorTests {
    ALCMethodMacroProcessor *_processor;
}

-(void) setUp {
	_processor = [[ALCMethodMacroProcessor alloc] init];
}

-(void) testAddMacroAcceptsALCArgMacros {
	[_processor addMacro:ACArg(NSString, ACValue(@5))];
	[_processor validate];
	XCTAssertEqualObjects(@5,[[[_processor valueSourceFactoryForIndex:0] valueSource].values anyObject]);
}

-(void) testAddMacroAcceptsObjectMacros {
	[_processor addMacro:ACIsFactory];
	[_processor addMacro:ACIsPrimary];
	[_processor addMacro:ACWithName(@"abc")];
	[_processor validate];
	XCTAssertTrue(_processor.isFactory);
	XCTAssertTrue(_processor.isPrimary);
	XCTAssertEqualObjects(@"abc", _processor.asName);
}

-(void) testAddMacroRejectsDefMacros {
	XCTAssertThrowsSpecificNamed([_processor addMacro:ACName(@"abc")], NSException, @"AlchemicUnexpectedMacro");
}


@end
