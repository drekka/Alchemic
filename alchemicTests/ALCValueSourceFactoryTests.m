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
	id<ALCValueSource> valueSource = [_factory valueSource];
	XCTAssertTrue([valueSource isKindOfClass:[ALCConstantValueSource class]]);
	XCTAssertEqualObjects(@5, [valueSource valueForType:[NSNumber class]]);
}

-(void) testValueSourceForModel {
	[_factory addMacro:AcName(@"abc")];
	id<ALCValueSource> valueSource = [_factory valueSource];
	XCTAssertTrue([valueSource isKindOfClass:[ALCModelValueSource class]]);
	NSSet<id<ALCModelSearchExpression>> *searchExpressions = ((ALCModelValueSource *)valueSource).searchExpressions;
	XCTAssertTrue([searchExpressions containsObject:AcName(@"abc")]);
}

-(void) testAddingConstantToOtherMacrosFails {
	[_factory addMacro:AcValue(@5)];
	XCTAssertThrowsSpecificNamed([_factory addMacro:AcClass(NSString)], NSException, @"AlchemicInvalidMacroCombination");
}

-(void) testAddingMacroToConstantFails {
    [_factory addMacro:AcClass(NSString)];
    XCTAssertThrowsSpecificNamed([_factory addMacro:AcValue(@5)], NSException, @"AlchemicInvalidMacroCombination");
}

-(void) testAddingNameToOtherMacrosFails {
    [_factory addMacro:AcName(@"abc")];
    XCTAssertThrowsSpecificNamed([_factory addMacro:AcClass(NSString)], NSException, @"AlchemicInvalidMacroCombination");
}

-(void) testAddingMacroToNameFails {
    [_factory addMacro:AcClass(NSString)];
    XCTAssertThrowsSpecificNamed([_factory addMacro:AcName(@"abc")], NSException, @"AlchemicInvalidMacroCombination");
}


-(void) testAddingMoreThanOneClassFails {
    [_factory addMacro:AcClass(NSString)];
    XCTAssertThrowsSpecificNamed([_factory addMacro:AcClass(NSNumber)], NSException, @"AlchemicInvalidMacroCombination");
}


@end
