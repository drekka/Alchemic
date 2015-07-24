//
//  ALCClassRegistrationMacroProcessorTests.m
//  Alchemic
//
//  Created by Derek Clarkson on 24/07/2015.
//  Copyright © 2015 Derek Clarkson. All rights reserved.
//

@import XCTest;
#import "ALCClassRegistrationMacroProcessor.h"
#import <Alchemic/Alchemic.h>

@interface ALCClassRegistrationMacroProcessorTests : XCTestCase

@end

@implementation ALCClassRegistrationMacroProcessorTests {
	ALCClassRegistrationMacroProcessor *_processor;
}

-(void) setUp {
	_processor = [[ALCClassRegistrationMacroProcessor alloc] init];
}

-(void) testRejectsACArgMacro {
XCTAssertThrowsSpecificNamed(([_processor addMacro:ACArg(NSString, ACName(@"abc"))]), NSException, @"AlchemicUnexpectedMacro");
}

-(void) testRejectsOtherDefMacro {
	XCTAssertThrowsSpecificNamed(([_processor addMacro:ACName(@"abc")]), NSException, @"AlchemicUnexpectedMacro");
}

-(void) testAcceptsNonDefMacro {
	[_processor addMacro:ACIsFactory];
	XCTAssertTrue(_processor.isFactory);
}


@end
