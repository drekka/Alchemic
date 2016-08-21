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
@end

@interface AlchemicTests : XCTestCase

@end

@implementation AlchemicTests

-(void) testInitializeCallsInitContext {

    id mockProcessInfo = OCMClassMock([NSProcessInfo class]);
    OCMStub(ClassMethod([mockProcessInfo processInfo])).andReturn(mockProcessInfo);
    OCMStub([(NSProcessInfo *)mockProcessInfo arguments]).andReturn(@[]);

    id mockAlchemic = OCMClassMock([Alchemic class]);
    OCMExpect(ClassMethod([mockAlchemic initContext]));

    [Alchemic initialize];

    [mockProcessInfo stopMocking];
    [mockAlchemic stopMocking];
}





@end
