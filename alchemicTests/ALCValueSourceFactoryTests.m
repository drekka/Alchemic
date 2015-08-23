//
//  ALCArgumentFactoryTests.m
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

@interface ALCArgumentFactoryTests : XCTestCase
@end

@implementation ALCArgumentFactoryTests

-(void) testValueSourceForConstant {
    ALCValueSourceFactory *factory = [[ALCValueSourceFactory alloc] initWithType:[NSNumber class]];
	[factory addMacro:AcValue(@5)];
	id<ALCValueSource> valueSource = [factory valueSource];
    [valueSource resolveWithPostProcessors:[NSSet set] dependencyStack:[NSMutableArray array]];
	XCTAssertTrue([valueSource isKindOfClass:[ALCConstantValueSource class]]);
	XCTAssertEqualObjects(@5, valueSource.value);
}

-(void) testValueSourceForModel {
    ALCValueSourceFactory *factory = [[ALCValueSourceFactory alloc] initWithType:[NSNumber class]];
	[factory addMacro:AcName(@"abc")];
	id<ALCValueSource> valueSource = [factory valueSource];
	XCTAssertTrue([valueSource isKindOfClass:[ALCModelValueSource class]]);
	NSSet<id<ALCModelSearchExpression>> *searchExpressions = ((ALCModelValueSource *)valueSource).searchExpressions;
	XCTAssertTrue([searchExpressions containsObject:AcName(@"abc")]);
}

-(void) testAddingConstantToOtherMacrosFails {
    ALCValueSourceFactory *factory = [[ALCValueSourceFactory alloc] initWithType:[NSNumber class]];
	[factory addMacro:AcValue(@5)];
	XCTAssertThrowsSpecificNamed([factory addMacro:AcClass(NSString)], NSException, @"AlchemicInvalidMacroCombination");
}

-(void) testAddingMacroToConstantFails {
    ALCValueSourceFactory *factory = [[ALCValueSourceFactory alloc] initWithType:[NSNumber class]];
    [factory addMacro:AcClass(NSString)];
    XCTAssertThrowsSpecificNamed([factory addMacro:AcValue(@5)], NSException, @"AlchemicInvalidMacroCombination");
}

-(void) testAddingNameToOtherMacrosFails {
    ALCValueSourceFactory *factory = [[ALCValueSourceFactory alloc] initWithType:[NSNumber class]];
    [factory addMacro:AcName(@"abc")];
    XCTAssertThrowsSpecificNamed([factory addMacro:AcClass(NSString)], NSException, @"AlchemicInvalidMacroCombination");
}

-(void) testAddingMacroToNameFails {
    ALCValueSourceFactory *factory = [[ALCValueSourceFactory alloc] initWithType:[NSNumber class]];
    [factory addMacro:AcClass(NSString)];
    XCTAssertThrowsSpecificNamed([factory addMacro:AcName(@"abc")], NSException, @"AlchemicInvalidMacroCombination");
}


-(void) testAddingMoreThanOneClassFails {
    ALCValueSourceFactory *factory = [[ALCValueSourceFactory alloc] initWithType:[NSNumber class]];
    [factory addMacro:AcClass(NSString)];
    XCTAssertThrowsSpecificNamed([factory addMacro:AcClass(NSNumber)], NSException, @"AlchemicInvalidMacroCombination");
}

@end
