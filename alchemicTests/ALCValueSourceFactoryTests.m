//
//  ALCValueSourceFactoryTests.m
//  Alchemic
//
//  Created by Derek Clarkson on 24/07/2015.
//  Copyright © 2015 Derek Clarkson. All rights reserved.
//

@import XCTest;
#import "ALCValueSourceFactory.h"
#import <Alchemic/Alchemic.h>
#import "ALCConstantValueSource.h"
#import "ALCModelValueSource.h"

@interface ALCValueSourceFactoryTests : XCTestCase
@end

@implementation ALCValueSourceFactoryTests {
	ALCValueSourceFactory *_factory;
}

-(void) setUp {
	_factory = [[ALCValueSourceFactory alloc] init];
}

-(void) testValueSourceForConstant {
	[_factory addMacro:AcValue(@5)];
	[_factory validate];
	id<ALCValueSource> valueSource = [_factory valueSource];
	XCTAssertTrue([valueSource isKindOfClass:[ALCConstantValueSource class]]);
	XCTAssertEqualObjects(@5, [valueSource valueForType:[NSNumber class]]);
}

-(void) testValueSourceForModel {
	[_factory addMacro:AcName(@"abc")];
	[_factory validate];
	id<ALCValueSource> valueSource = [_factory valueSource];
	XCTAssertTrue([valueSource isKindOfClass:[ALCModelValueSource class]]);
	NSSet<id<ALCModelSearchExpression>> *searchExpressions = ((ALCModelValueSource *)valueSource).searchExpressions;
	XCTAssertTrue([searchExpressions containsObject:AcName(@"abc")]);
}

-(void) testValidateFailsWhenConstantAndSearchExpression {
	[_factory addMacro:AcValue(@5)];
	[_factory addMacro:AcName(@"abc")];
	XCTAssertThrowsSpecificNamed([_factory validate], NSException, @"AlchemicInvalidArguments");
}

@end
