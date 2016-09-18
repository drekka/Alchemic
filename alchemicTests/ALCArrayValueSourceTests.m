//
//  ALCArrayValueSourceTests.m
//  Alchemic
//
//  Created by Derek Clarkson on 1/9/16.
//  Copyright © 2016 Derek Clarkson. All rights reserved.
//

@import XCTest;
@import Alchemic;
@import Alchemic.Private;
@import OCMock;

@interface ALCArrayValueSourceTests : XCTestCase
@end

@implementation ALCArrayValueSourceTests {
    ALCArrayValueSource *_source;
    id _mockOtherValueSource;
}

-(void)setUp {
    _mockOtherValueSource = OCMProtocolMock(@protocol(ALCValueSource));
    _source = [ALCArrayValueSource valueSourceWithValueSources:@[_mockOtherValueSource]];
}

-(void) testResolveWithStackModel {
    NSMutableArray *stack = [NSMutableArray array];
    id mockModel = OCMProtocolMock(@protocol(ALCModel));
    OCMExpect([_mockOtherValueSource resolveWithStack:stack model:mockModel]);

    [_source resolveWithStack:stack model:mockModel];

    OCMVerifyAll(_mockOtherValueSource);
}

-(void) testValueReturnsValue {

    // Mock out a ALCValue.
    id mockValue = OCMClassMock([ALCValue class]);
    OCMStub([(ALCValue *) mockValue value]).andReturn(@"abc");
    __block BOOL completionCalled;
    ALCSimpleBlock completion = ^{
        completionCalled = YES;
    };
    OCMStub([mockValue completion]).andReturn(completion);
    
    // Have the other data source return the value.
    OCMStub([(id<ALCValueSource>)_mockOtherValueSource value]).andReturn(mockValue);

    // Call the method.
    id result = _source.value;

    // Assert we have been given back the value.
    XCTAssertTrue([result isKindOfClass:[ALCValue class]]);
    ALCValue *value = result;

    NSArray *actualResults = value.value;
    XCTAssertEqual(1u, actualResults.count);
    XCTAssertEqualObjects(@"abc", actualResults[0]);
    
    // And that the completions have been assembled.
    value.completion();
    XCTAssertTrue(completionCalled);
}

-(void) testReferencesObjectFactoryPassesRequestToSources {
    id mockOf = OCMProtocolMock(@protocol(ALCObjectFactory));
    OCMStub([_mockOtherValueSource referencesObjectFactory:mockOf]).andReturn(YES);

    XCTAssertTrue([_source referencesObjectFactory:mockOf]);
}

-(void) testReferencesObjectFactoryDefaultsToFalse {
    id mockOf = OCMProtocolMock(@protocol(ALCObjectFactory));
    OCMStub([_mockOtherValueSource referencesObjectFactory:mockOf]).andReturn(NO);
    
    XCTAssertFalse([_source referencesObjectFactory:mockOf]);
}

-(void) testIsReadyWhenSourcesAreReady {
    OCMStub([_mockOtherValueSource isReady]).andReturn(YES);
    XCTAssertTrue(_source.isReady);
}

-(void) testIsReadyWhenSourcesAreNotReady {
    OCMStub([_mockOtherValueSource isReady]).andReturn(NO);
    XCTAssertFalse(_source.isReady);
}

-(void) testResolvingDescription {
    XCTAssertEqualObjects(@"array of value sources", _source.resolvingDescription);
}

@end
