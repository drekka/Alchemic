//
//  ALCAbstractDependencyTests.m
//  Alchemic
//
//  Created by Derek Clarkson on 21/8/16.
//  Copyright © 2016 Derek Clarkson. All rights reserved.
//

@import XCTest;
@import Alchemic;
@import Alchemic.Private;
@import OCMock;

@interface ALCAbstractDependencyTests : XCTestCase

@end

@implementation ALCAbstractDependencyTests {
    ALCAbstractDependency *_dep;
    id _mockValueSource;
}

-(void)setUp {
    _mockValueSource = OCMProtocolMock(@protocol(ALCValueSource));
    _dep = [[ALCAbstractDependency alloc] initWithType:[ALCType typeWithClass:[NSString class]] valueSource:_mockValueSource];
}

-(void) testReady {
    OCMStub([_mockValueSource isReady]).andReturn(YES);
    XCTAssertTrue(_dep.isReady);
}

-(void) testResolveWithStackModel {

    NSMutableArray *stack = [[NSMutableArray alloc] init];
    id mockModel = OCMProtocolMock(@protocol(ALCModel));

    OCMExpect([_mockValueSource resolveWithStack:stack model:mockModel]);

    id partialAbstractDependency = OCMPartialMock(_dep);
    OCMStub([partialAbstractDependency resolvingDescription]).andReturn(@"abc");

    [_dep resolveWithStack:stack model:mockModel];
}

-(void) testReferencesobjectFactory {
    id mockFactory = OCMProtocolMock(@protocol(ALCObjectFactory));
    OCMStub([_mockValueSource referencesObjectFactory:mockFactory]).andReturn(YES);
    XCTAssertTrue([_dep referencesObjectFactory:mockFactory]);
}

-(void) testResolvingDescription {
    XCTAssertThrows([_dep resolvingDescription]);
}

-(void) testStackName {
    XCTAssertThrows([_dep stackName]);
}

-(void) testInjectObject {
    id obj = OCMClassMock([NSObject class]);
    XCTAssertThrows([_dep injectObject:obj]);
}

@end
