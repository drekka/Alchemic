//
//  ALCContextImplTests.m
//  Alchemic
//
//  Created by Derek Clarkson on 28/06/2016.
//  Copyright © 2016 Derek Clarkson. All rights reserved.
//

@import XCTest;
@import Alchemic;
@import Alchemic.Private;
@import OCMock;
@import ObjectiveC;

@interface ALCContextImplTests : XCTestCase

@end

@implementation ALCContextImplTests {
    id<ALCContext> _context;
    id _mockModel;
}

- (void)setUp {
    _context = [[ALCContextImpl alloc] init];
    Ivar modelVar = [ALCRuntime class:[ALCContextImpl class] variableForInjectionPoint:@"_model"];
    _mockModel = OCMClassMock([ALCModelImpl class]);
    [ALCRuntime setObject:_context variable:modelVar withValue:(NSObject *)_mockModel];
}

-(void) testStart {
    OCMExpect([_mockModel resolveDependencies]);
    OCMExpect([_mockModel startSingletons]);

    [self expectationForNotification:AlchemicDidFinishStarting object:_context handler:nil];

    [_context start];

    [self waitForExpectationsWithTimeout:0.5 handler:nil];

    OCMVerifyAll(_mockModel);
}

-(void) testStartWithWaitingBlock {

    OCMExpect([_mockModel resolveDependencies]);
    OCMExpect([_mockModel startSingletons]);

    XCTestExpectation *blockExpectation = [self expectationWithDescription:@"blockFinished"];
    [self expectationForNotification:AlchemicDidFinishStarting object:_context handler:nil];

    [_context executeBlockWhenStarted:^{
        [blockExpectation fulfill];
    }];

    [_context start];

    [self waitForExpectationsWithTimeout:0.5 handler:nil];

    OCMVerifyAll(_mockModel);
}

-(void) testExecuteBlockAfterStart {

    OCMExpect([_mockModel resolveDependencies]);
    OCMExpect([_mockModel startSingletons]);

    XCTestExpectation *blockExpectation = [self expectationWithDescription:@"blockFinished"];

    [_context start];

    [_context executeBlockWhenStarted:^{
        [blockExpectation fulfill];
    }];

    [self waitForExpectationsWithTimeout:0.5 handler:nil];

    OCMVerifyAll(_mockModel);
}

-(void) testRegisterObjectFactoryForClass {
    OCMExpect([_mockModel addObjectFactory:[OCMArg checkWithBlock:^BOOL(id<ALCObjectFactory> objectFactory) {
        return objectFactory != nil;
    }]
                                  withName:@"NSString"]);
    id<ALCObjectFactory> objF = [_context registerObjectFactoryForClass:[NSString class]];
    XCTAssertEqual([NSString class], objF.objectClass);
}

-(void) testObjectFactoryConfig {
    id mockObjectFactory = OCMProtocolMock(@protocol(ALCObjectFactory));
    OCMExpect([mockObjectFactory configureWithOptions:[OCMArg checkWithBlock:^BOOL(NSArray *options) {
        return [ALCIsReference macro] == options[0];
    }]
                                                model:_mockModel]);
    [_context objectFactoryConfig:mockObjectFactory, AcReference, nil];
}

-(void) testObjectFactoryRegisterFactoryMethodReturnType {
    OCMExpect([_mockModel addObjectFactory:[OCMArg checkWithBlock:^BOOL(ALCMethodObjectFactory *objectFactory) {
        return objectFactory.selector == @selector(description);
    }]
                                  withName:@"-[NSString description]"]);
}

@end
