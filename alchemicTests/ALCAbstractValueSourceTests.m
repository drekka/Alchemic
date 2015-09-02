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

-(void) testNowAvailableCallsBlock {
    __block BOOL blockCalled;
    [self setUpAndResolveValueSourceClass:[NSObject class] toReturn:@[@"abc"] whenAvailable:^(ALCWhenAvailableBlockArgs){
        blockCalled = YES;
    }];
    [_valueSource nowAvailable];
}

-(void) testNotAvailableWhenValueAccessed {
    [self setUpWithValueSourceClass:[NSObject class] toReturn:@[@"abc"] whenAvailable:NULL];
    XCTAssertThrowsSpecificNamed(_valueSource.value, NSException, @"AlchemicValueNotAvailable");
}

#pragma mark - Values

-(void) testObjectValueWhenSingleValue {
    [self setUpAndResolveValueSourceClass:[NSObject class] toReturn:@[@"abc"] whenAvailable:NULL];
    id result = _valueSource.value;
    XCTAssertTrue([result isKindOfClass:[NSString class]]);
    XCTAssertEqualObjects(@"abc", result);
}

-(void) testObjectValueWhenMultipleValue {
    [self setUpAndResolveValueSourceClass:[NSObject class] toReturn:@[@"abc", @"def"] whenAvailable:NULL];
    id result = _valueSource.value;
    XCTAssertTrue([result isKindOfClass:[NSArray class]]);
    XCTAssertTrue([result containsObject:@"abc"]);
    XCTAssertTrue([result containsObject:@"def"]);
}

-(void) testObjectValueWhenNoValuesThrows {
    [self setUpAndResolveValueSourceClass:[NSObject class] toReturn:@[] whenAvailable:NULL];
    XCTAssertThrowsSpecificNamed(_valueSource.value, NSException, @"AlchemicNoValuesFound");
}

-(void) testStringValueWhenMultipleValuesThrows {
    [self setUpAndResolveValueSourceClass:[NSString class] toReturn:@[@"abc", @"def"] whenAvailable:NULL];
    XCTAssertThrowsSpecificNamed(_valueSource.value, NSException, @"AlchemicTooManyValues");
}

-(void) testArrayValueWhenSingleValue {
    [self setUpAndResolveValueSourceClass:[NSArray class] toReturn:@[@"abc"] whenAvailable:NULL];
    id result = _valueSource.value;
    XCTAssertTrue([result isKindOfClass:[NSArray class]]);
    XCTAssertEqual(1u, [result count]);
    XCTAssertEqualObjects(@"abc", result[0]);
}

-(void) testArrayValueWhenNoValuesThrows {
    [self setUpAndResolveValueSourceClass:[NSArray class] toReturn:@[] whenAvailable:NULL];
    id result = _valueSource.value;
    XCTAssertTrue([result isKindOfClass:[NSArray class]]);
    XCTAssertEqual(0u, [result count]);
}

-(void) testArrayValueWhenMultipleValuesThrows {
    [self setUpAndResolveValueSourceClass:[NSArray class] toReturn:@[@"abc", @"def"] whenAvailable:NULL];
    id result = _valueSource.value;
    XCTAssertTrue([result isKindOfClass:[NSArray class]]);
    XCTAssertEqual(2u, [result count]);
    XCTAssertTrue([result containsObject:@"abc"]);
    XCTAssertTrue([result containsObject:@"def"]);
}

-(void) testArrayValueWhenSingleValueIsArray {
    [self setUpAndResolveValueSourceClass:[NSArray class] toReturn:@[@[@"abc"]] whenAvailable:NULL];
    id result = _valueSource.value;
    XCTAssertTrue([result isKindOfClass:[NSArray class]]);
    XCTAssertEqual(1u, [result count]);
    XCTAssertEqualObjects(@"abc", result[0]);
}

#pragma mark - Override points

-(void) testResolveWithPostProcessors {
    [self setUpWithValueSourceClass:[NSString class] toReturn:@[] whenAvailable:NULL];
    XCTAssertThrowsSpecificNamed([_valueSource resolveWithPostProcessors:[NSSet set] dependencyStack:[NSMutableArray array]], NSException, @"NSInvalidArgumentException");
}

-(void) testValues {
    ALCAbstractValueSource *abstractSource = [[ALCAbstractValueSource alloc] initWithType:[NSObject class] whenAvailable:NULL];
    XCTAssertThrowsSpecificNamed(abstractSource.values, NSException, @"NSInvalidArgumentException");
}

#pragma mark - Internal

-(void) setUpAndResolveValueSourceClass:(Class) vsClass
                               toReturn:(NSArray *) values
                          whenAvailable:(ALCWhenAvailableBlock) whenAvailable {
    [self setUpWithValueSourceClass:vsClass toReturn:values whenAvailable:whenAvailable];
    [_valueSource nowAvailable];
}

-(void) setUpWithValueSourceClass:(Class) vsClass
                         toReturn:(NSArray *) values
                    whenAvailable:(ALCWhenAvailableBlock) whenAvailable {
    _valueSource = [[ALCAbstractValueSource alloc] initWithType:vsClass
                                                  whenAvailable:whenAvailable];
    _mockValueSource = OCMPartialMock(_valueSource);
    NSSet *valueSet = [NSSet setWithArray:values];
    OCMStub([(ALCAbstractValueSource *)_mockValueSource values]).andReturn(valueSet);
}

@end
