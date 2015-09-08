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
    ALCAbstractValueSource *_valueSource;
    id _mockValueSource;
}

-(void) testNotAvailableWhenValueAccessed {
    [self setUpWithValueSourceClass:[NSObject class] toReturn:@[]];
    XCTAssertThrowsSpecificNamed(_valueSource.value, NSException, @"AlchemicNoValuesFound");
}

#pragma mark - Values

-(void) testObjectValueWhenSingleValue {
    [self setUpWithResolvedValueSourceClass:[NSObject class] toReturn:@[@"abc"]];
    id result = _valueSource.value;
    XCTAssertTrue([result isKindOfClass:[NSString class]]);
    XCTAssertEqualObjects(@"abc", result);
}

-(void) testObjectValueWhenMultipleValue {
    [self setUpWithResolvedValueSourceClass:[NSObject class] toReturn:@[@"abc", @"def"]];
    id result = _valueSource.value;
    XCTAssertTrue([result isKindOfClass:[NSArray class]]);
    XCTAssertTrue([result containsObject:@"abc"]);
    XCTAssertTrue([result containsObject:@"def"]);
}

-(void) setUpWithResolvedValueSourceClass {
    [self setUpWithResolvedValueSourceClass:[NSObject class] toReturn:@[]];
    XCTAssertThrowsSpecificNamed(_valueSource.value, NSException, @"AlchemicNoValuesFound");
}

-(void) testStringValueWhenMultipleValuesThrows {
    [self setUpWithResolvedValueSourceClass:[NSString class] toReturn:@[@"abc", @"def"]];
    XCTAssertThrowsSpecificNamed(_valueSource.value, NSException, @"AlchemicTooManyValues");
}

-(void) testArrayValueWhenSingleValue {
    [self setUpWithResolvedValueSourceClass:[NSArray class] toReturn:@[@"abc"]];
    id result = _valueSource.value;
    XCTAssertTrue([result isKindOfClass:[NSArray class]]);
    XCTAssertEqual(1u, [result count]);
    XCTAssertEqualObjects(@"abc", result[0]);
}

-(void) testArrayValueWhenNoValuesThrows {
    [self setUpWithResolvedValueSourceClass:[NSArray class] toReturn:@[]];
    id result = _valueSource.value;
    XCTAssertTrue([result isKindOfClass:[NSArray class]]);
    XCTAssertEqual(0u, [result count]);
}

-(void) testArrayValueWhenMultipleValuesThrows {
    [self setUpWithResolvedValueSourceClass:[NSArray class] toReturn:@[@"abc", @"def"]];
    id result = _valueSource.value;
    XCTAssertTrue([result isKindOfClass:[NSArray class]]);
    XCTAssertEqual(2u, [result count]);
    XCTAssertTrue([result containsObject:@"abc"]);
    XCTAssertTrue([result containsObject:@"def"]);
}

-(void) testArrayValueWhenSingleValueIsArray {
    [self setUpWithResolvedValueSourceClass:[NSArray class] toReturn:@[@[@"abc"]]];
    id result = _valueSource.value;
    XCTAssertTrue([result isKindOfClass:[NSArray class]]);
    XCTAssertEqual(1u, [result count]);
    XCTAssertEqualObjects(@"abc", result[0]);
}

#pragma mark - Override points

-(void) testValues {
    ALCAbstractValueSource *abstractSource = [[ALCAbstractValueSource alloc] initWithType:[NSObject class]];
    XCTAssertThrowsSpecificNamed(abstractSource.values, NSException, @"NSInternalInconsistencyException");
}

#pragma mark - Internal

-(void) setUpWithResolvedValueSourceClass:(Class) vsClass toReturn:(NSArray *) values {
    [self setUpWithValueSourceClass:vsClass toReturn:values];
    [_valueSource resolveWithDependencyStack:[NSMutableArray array]];
}

-(void) setUpWithValueSourceClass:(Class) vsClass toReturn:(NSArray *) values {
    _valueSource = [[ALCAbstractValueSource alloc] initWithType:vsClass];
    [_valueSource resolveWithDependencyStack:[NSMutableArray array]];
    _mockValueSource = OCMPartialMock(_valueSource);
    NSSet *valueSet = [NSSet setWithArray:values];
    OCMStub([(ALCAbstractValueSource *)_mockValueSource values]).andReturn(valueSet);
}

@end
