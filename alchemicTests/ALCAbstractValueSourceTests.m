//
//  ALCAbstractValueSourceTests.m
//  Alchemic
//
//  Created by Derek Clarkson on 24/07/2015.
//  Copyright © 2015 Derek Clarkson. All rights reserved.
//

@import XCTest;
#import "ALCAbstractValueSource.h"

@interface DummyValueSource : ALCAbstractValueSource
@property (nonatomic, strong) NSSet<id> *values;
@end

@implementation DummyValueSource
@end

@interface ALCAbstractValueSourceTests : XCTestCase

@end

@implementation ALCAbstractValueSourceTests {
	DummyValueSource *_source;
}

-(void) setUp {
	_source = [[DummyValueSource alloc] init];
}

-(void) testValueForTypeObjectWhenSingleValue {
	_source.values = [NSSet setWithObject:@"abc"];
	id result = [_source valueForType:[NSString class]];
	XCTAssertTrue([result isKindOfClass:[NSString class]]);
	XCTAssertEqualObjects(@"abc", result);
}

-(void) testValueForTypeObjectWhenNoValuesThrows {
	_source.values = [NSSet set];
	XCTAssertThrowsSpecificNamed([_source valueForType:[NSString class]], NSException, @"AlchemicNoValuesFound");
}

-(void) testValueForTypeObjectWhenMultipleValuesThrows {
	_source.values = [NSSet setWithObjects:@"abc", @"def", nil];
	XCTAssertThrowsSpecificNamed([_source valueForType:[NSString class]], NSException, @"AlchemicTooManyValues");
}

-(void) testValueForTypeArrayWhenSingleValue {
	_source.values = [NSSet setWithObject:@"abc"];
	id result = [_source valueForType:[NSArray class]];
	XCTAssertTrue([result isKindOfClass:[NSArray class]]);
	XCTAssertEqual(1u, [result count]);
	XCTAssertEqualObjects(@"abc", result[0]);
}

-(void) testValueForTypeArrayWhenNoValuesThrows {
	_source.values = [NSSet set];
	id result = [_source valueForType:[NSArray class]];
	XCTAssertTrue([result isKindOfClass:[NSArray class]]);
	XCTAssertEqual(0u, [result count]);
}

-(void) testValueForTypeArrayWhenMultipleValuesThrows {
	_source.values = [NSSet setWithObjects:@"abc", @"def", nil];
	id result = [_source valueForType:[NSArray class]];
	XCTAssertTrue([result isKindOfClass:[NSArray class]]);
	XCTAssertEqual(2u, [result count]);
	XCTAssertTrue([result containsObject:@"abc"]);
	XCTAssertTrue([result containsObject:@"def"]);
}

-(void) testValueForTypeArrayWhenSingleValueIsArray {
	_source.values = [NSSet setWithObject:@[@"abc"]];
	id result = [_source valueForType:[NSArray class]];
	XCTAssertTrue([result isKindOfClass:[NSArray class]]);
	XCTAssertEqual(1u, [result count]);
	XCTAssertEqualObjects(@"abc", result[0]);
}

@end
