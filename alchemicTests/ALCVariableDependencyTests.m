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
}

-(void)setUp {
    Ivar ivar = class_getInstanceVariable([self class], "aIvar");
    _injectorMock = OCMProtocolMock(@protocol(ALCInjector));
    _dependency = [ALCVariableDependency variableDependencyWithInjector:_injectorMock
                                                               intoIvar:ivar
                                                                   name:@"abc"];
}

-(void) testFactoryMethod {
    XCTAssertNotNil(_dependency);
    XCTAssertEqual(_injectorMock, _dependency.injector);
    XCTAssertEqualObjects(@"abc", _dependency.name);
}

-(void) testConfigureWithOptionsNillable {
    [_dependency configureWithOptions:@[AcNillable]];
    BOOL yes = YES;
    OCMExpect([_injectorMock setAllowNilValues:OCMOCK_VALUE(yes)]);
    OCMVerifyAll(_injectorMock);
}



@end
