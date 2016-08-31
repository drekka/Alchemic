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
    id _mockValueSource;
}

-(void)setUp {
    _mockValueSource = OCMProtocolMock(@protocol(ALCValueSource));
    _source = [ALCArrayValueSource valueSourceWithValueSources:@[_mockValueSource]];
}

-(void) testResolveWithStackModel {
    NSMutableArray *stack = [NSMutableArray array];
    id mockModel = OCMProtocolMock(@protocol(ALCModel));
    OCMExpect([_mockValueSource resolveWithStack:stack model:mockModel]);

    [_source resolveWithStack:stack model:mockModel];

    OCMVerifyAll(_mockValueSource);
}

-(void) testValueWithErrorReturnsValue {

    id mockValue = OCMClassMock([ALCValue class]);
    NSError *error;
    OCMStub([_mockValueSource valueWithError:[OCMArg anyObjectRef]]).andReturn(mockValue);

    id result = [_source valueWithError:&error];

    XCTAssertEqual(mockValue, result);
}

@end
