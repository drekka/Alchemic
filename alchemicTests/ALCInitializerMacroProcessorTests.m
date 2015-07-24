//
//  ALCInitializerMacroProcessorTests.m
//  Alchemic
//
//  Created by Derek Clarkson on 24/07/2015.
//  Copyright © 2015 Derek Clarkson. All rights reserved.
//

@import XCTest;
#import "ALCInitializerMacroProcessor.h"
#import <Alchemic/Alchemic.h>
#import "ALCValueSource.h"


@interface ALCInitializerMacroProcessorTests : XCTestCase

@end

@implementation ALCInitializerMacroProcessorTests {
	ALCInitializerMacroProcessor *_processor;
}

-(void) setUp {
	_processor = [[ALCInitializerMacroProcessor alloc] init];
}

-(void) testAddMacroAcceptsALCArg {
	[_processor addMacro:AcArg(NSString, AcValue(@5))];
	[_processor validate];
	XCTAssertEqualObjects(@5,[[[_processor valueSourceFactoryForIndex:0] valueSource] valueForType:[NSNumber class]]);
}

-(void) testAddMacroRejectsNonALCArgMacros {
	XCTAssertThrowsSpecificNamed([_processor addMacro:ACIsFactory], NSException, @"AlchemicUnexpectedMacro");
	XCTAssertThrowsSpecificNamed([_processor addMacro:AcName(@"abc")], NSException, @"AlchemicUnexpectedMacro");
}


@end
