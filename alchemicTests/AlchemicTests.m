//
//  AlchemicTests.m
//  Alchemic
//
//  Created by Derek Clarkson on 21/8/16.
//  Copyright © 2016 Derek Clarkson. All rights reserved.
//

@import XCTest;
@import Alchemic;
@import Alchemic.Private;
@import OCMock;

@interface Alchemic (_hack)
+(void) initContext;
+(void) dropContext;
@end

@interface AlchemicTests : XCTestCase

@end

@implementation AlchemicTests

-(void) tearDown {
    [Alchemic dropContext];
}

-(void) testInitializeCallsInitContext {

    id mockProcessInfo = OCMClassMock([NSProcessInfo class]);
    OCMStub(ClassMethod([mockProcessInfo processInfo])).andReturn(mockProcessInfo);
    OCMStub([(NSProcessInfo *)mockProcessInfo arguments]).andReturn(@[]);

    [Alchemic initialize];

    [mockProcessInfo stopMocking];

    XCTAssertNotNil([Alchemic mainContext]);
}


@end
