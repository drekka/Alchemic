//
//  ALCVariableDependencyTests.m
//  alchemic
//
//  Created by Derek Clarkson on 21/07/2016.
//  Copyright © 2016 Derek Clarkson. All rights reserved.
//

@import XCTest;
@import Alchemic;
@import Alchemic.Private;
@import ObjectiveC;
@import OCMock;

@interface ALCVariableDependencyTests : XCTestCase

@end

@implementation ALCVariableDependencyTests {
    id aIvar;
    ALCVariableDependency *_dependency;
    id _injectorMock;
    Ivar _ivar;
}

-(void)setUp {
    _ivar = class_getInstanceVariable([self class], "aIvar");
    _injectorMock = OCMProtocolMock(@protocol(ALCInjector));
    _dependency = [ALCVariableDependency variableDependencyWithInjector:_injectorMock
                                                               intoIvar:_ivar
                                                                   name:@"abc"];
}

-(void) testFactoryMethod {
    XCTAssertNotNil(_dependency);
    XCTAssertEqual(_injectorMock, _dependency.injector);
    XCTAssertEqualObjects(@"abc", _dependency.name);
}

#pragma mark - Configuring

-(void) testConfigureWithOptionsNillable {
    OCMExpect([_injectorMock setAllowNilValues:YES]);
    [_dependency configureWithOptions:@[AcNillable]];
    OCMVerifyAll(_injectorMock);
}

-(void) testConfigureWithOptionsTransient {
    OCMExpect([_injectorMock setAllowNilValues:YES]);
    [_dependency configureWithOptions:@[AcTransient]];
    OCMVerifyAll(_injectorMock);
    XCTAssertTrue(_dependency.transient);
}

-(void) testConfigureWithOptionsUnknownOption {
    XCTAssertThrowsSpecific(([_dependency configureWithOptions:@[@"XXX"]]), AlchemicIllegalArgumentException);
}

#pragma mark - Naming

-(void) testStackName {
    XCTAssertEqualObjects(@"abc", _dependency.stackName);
}

-(void) testResolvingDescription {
    XCTAssertEqualObjects(@"Variable abc", _dependency.resolvingDescription);
}

#pragma mark - Injecting

-(void) testInjecting {
    OCMExpect([_injectorMock setObject:@"abc" variable:_ivar]);
    [_dependency injectObject:@"abc"];
    OCMVerifyAll(_injectorMock);
}

@end
