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

@implementation ALCAbstractValueSourceTests

-(void) testObjectValueWhenSingleValue {
    DummyValueSource *source = [[DummyValueSource alloc] initWithType:[NSObject class]];
	source.values = [NSSet setWithObject:@"abc"];
	id result =source.value;
	XCTAssertTrue([result isKindOfClass:[NSString class]]);
	XCTAssertEqualObjects(@"abc", result);
}

-(void) testObjectValueWhenMultipleValue {
    DummyValueSource *source = [[DummyValueSource alloc] initWithType:[NSObject class]];
	source.values = [NSSet setWithObjects:@"abc", @"def", nil];
	id result =source.value;
	XCTAssertTrue([result isKindOfClass:[NSArray class]]);
	XCTAssertTrue([result containsObject:@"abc"]);
	XCTAssertTrue([result containsObject:@"def"]);
}

-(void) testObjectValueWhenNoValuesThrows {
    DummyValueSource *source = [[DummyValueSource alloc] initWithType:[NSObject class]];
	source.values = [NSSet set];
	XCTAssertThrowsSpecificNamed(source.value, NSException, @"AlchemicNoValuesFound");
}

-(void) testStringValueWhenMultipleValuesThrows {
    DummyValueSource *source = [[DummyValueSource alloc] initWithType:[NSString class]];
	source.values = [NSSet setWithObjects:@"abc", @"def", nil];
	XCTAssertThrowsSpecificNamed(source.value, NSException, @"AlchemicTooManyValues");
}

-(void) testArrayValueWhenSingleValue {
    DummyValueSource *source = [[DummyValueSource alloc] initWithType:[NSArray class]];
	source.values = [NSSet setWithObject:@"abc"];
	id result = source.value;
	XCTAssertTrue([result isKindOfClass:[NSArray class]]);
	XCTAssertEqual(1u, [result count]);
	XCTAssertEqualObjects(@"abc", result[0]);
}

-(void) testArrayValueWhenNoValuesThrows {
    DummyValueSource *source = [[DummyValueSource alloc] initWithType:[NSArray class]];
	source.values = [NSSet set];
	id result = source.value;
	XCTAssertTrue([result isKindOfClass:[NSArray class]]);
	XCTAssertEqual(0u, [result count]);
}

-(void) testArrayValueWhenMultipleValuesThrows {
    DummyValueSource *source = [[DummyValueSource alloc] initWithType:[NSArray class]];
	source.values = [NSSet setWithObjects:@"abc", @"def", nil];
	id result = source.value;
	XCTAssertTrue([result isKindOfClass:[NSArray class]]);
	XCTAssertEqual(2u, [result count]);
	XCTAssertTrue([result containsObject:@"abc"]);
	XCTAssertTrue([result containsObject:@"def"]);
}

-(void) testArrayValueWhenSingleValueIsArray {
    DummyValueSource *source = [[DummyValueSource alloc] initWithType:[NSArray class]];
	source.values = [NSSet setWithObject:@[@"abc"]];
	id result = source.value;
	XCTAssertTrue([result isKindOfClass:[NSArray class]]);
	XCTAssertEqual(1u, [result count]);
	XCTAssertEqualObjects(@"abc", result[0]);
}

#pragma mark - Overrides

-(void) testResolveWithPostProcessors {
    DummyValueSource *source = [[DummyValueSource alloc] initWithType:[NSObject class]];
	[source resolveWithPostProcessors:[NSSet set]];
	XCTAssertTrue(source.resolved);
}

-(void) testValues {
	ALCAbstractValueSource *abstractSource = [[ALCAbstractValueSource alloc] initWithType:[NSObject class]];
	XCTAssertThrowsSpecificNamed([abstractSource values], NSException, @"NSInvalidArgumentException");
}

@end
