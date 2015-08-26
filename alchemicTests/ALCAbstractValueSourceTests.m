//
//  ALCAbstractValueSourceTests.m
//  Alchemic
//
//  Created by Derek Clarkson on 24/07/2015.
//  Copyright © 2015 Derek Clarkson. All rights reserved.
//

@import XCTest;

#import <OCMock/OCMock.h>
#import "ALCResolvable.h"
#import "ALCAbstractValueSource.h"

@interface ALCAbstractValueSourceTests : XCTestCase

@end

@implementation ALCAbstractValueSourceTests {
    id<ALCValueSource> _valueSource;
    id _mockValueSource;
}

-(void) setUpWithValueSourceClass:(Class) vsClass toReturn:(NSArray *) values {
    _valueSource = [[ALCAbstractValueSource alloc] initWithType:vsClass];
    _mockValueSource = OCMPartialMock(_valueSource);
    NSSet *valueSet = [NSSet setWithArray:values];
    OCMStub([(ALCAbstractValueSource *)_mockValueSource available]).andReturn(YES);
    OCMStub([(ALCAbstractValueSource *)_mockValueSource values]).andReturn(valueSet);
}

-(void) testObjectValueWhenSingleValue {
    [self setUpWithValueSourceClass:[NSObject class] toReturn:@[@"abc"]];
	id result = _valueSource.value;
	XCTAssertTrue([result isKindOfClass:[NSString class]]);
	XCTAssertEqualObjects(@"abc", result);
}

-(void) testObjectValueWhenMultipleValue {
    [self setUpWithValueSourceClass:[NSObject class] toReturn:@[@"abc", @"def"]];
    id result = _valueSource.value;
	XCTAssertTrue([result isKindOfClass:[NSArray class]]);
	XCTAssertTrue([result containsObject:@"abc"]);
	XCTAssertTrue([result containsObject:@"def"]);
}

-(void) testObjectValueWhenNoValuesThrows {
    [self setUpWithValueSourceClass:[NSObject class] toReturn:@[]];
	XCTAssertThrowsSpecificNamed(_valueSource.value, NSException, @"AlchemicNoValuesFound");
}

-(void) testStringValueWhenMultipleValuesThrows {
    [self setUpWithValueSourceClass:[NSString class] toReturn:@[@"abc", @"def"]];
	XCTAssertThrowsSpecificNamed(_valueSource.value, NSException, @"AlchemicTooManyValues");
}

-(void) testArrayValueWhenSingleValue {
    [self setUpWithValueSourceClass:[NSArray class] toReturn:@[@"abc"]];
	id result = _valueSource.value;
	XCTAssertTrue([result isKindOfClass:[NSArray class]]);
	XCTAssertEqual(1u, [result count]);
	XCTAssertEqualObjects(@"abc", result[0]);
}

-(void) testArrayValueWhenNoValuesThrows {
    [self setUpWithValueSourceClass:[NSArray class] toReturn:@[]];
    id result = _valueSource.value;
	XCTAssertTrue([result isKindOfClass:[NSArray class]]);
	XCTAssertEqual(0u, [result count]);
}

-(void) testArrayValueWhenMultipleValuesThrows {
    [self setUpWithValueSourceClass:[NSArray class] toReturn:@[@"abc", @"def"]];
    id result = _valueSource.value;
	XCTAssertTrue([result isKindOfClass:[NSArray class]]);
	XCTAssertEqual(2u, [result count]);
	XCTAssertTrue([result containsObject:@"abc"]);
	XCTAssertTrue([result containsObject:@"def"]);
}

-(void) testArrayValueWhenSingleValueIsArray {
    [self setUpWithValueSourceClass:[NSArray class] toReturn:@[@[@"abc"]]];
    id result = _valueSource.value;
	XCTAssertTrue([result isKindOfClass:[NSArray class]]);
	XCTAssertEqual(1u, [result count]);
	XCTAssertEqualObjects(@"abc", result[0]);
}

#pragma mark - Override points

-(void) testResolveWithPostProcessors {
    [self setUpWithValueSourceClass:[NSString class] toReturn:@[]];

    XCTAssertThrowsSpecificNamed([_valueSource resolveWithPostProcessors:[NSSet set] dependencyStack:[NSMutableArray array]], NSException, @"NSInvalidArgumentException");
}

-(void) testValues {
	ALCAbstractValueSource *abstractSource = [[ALCAbstractValueSource alloc] initWithType:[NSObject class]];
	XCTAssertThrowsSpecificNamed(abstractSource.values, NSException, @"NSInvalidArgumentException");
}

@end
