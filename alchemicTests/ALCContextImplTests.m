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
    NSObject<ALCContext> *_context;
    id _mockModel;
}

- (void)setUp {
    _context = [[ALCContextImpl alloc] init];
    Ivar modelVar = [ALCRuntime forClass:[ALCContextImpl class] variableForInjectionPoint:@"_model"];
    _mockModel = OCMClassMock([ALCModelImpl class]);
    object_setIvar(_context, modelVar, _mockModel);
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
                                  withName:nil]);
    id<ALCObjectFactory> objF = [_context registerObjectFactoryForClass:[NSString class]];
    XCTAssertEqual([NSString class], objF.type.objcClass);
    OCMVerifyAll(_mockModel);
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

    id mockParentObjectFactory = OCMProtocolMock(@protocol(ALCObjectFactory));
    ALCType *type = [ALCType typeWithClass:[NSString class]];
    OCMStub([(id<ALCObjectFactory>) mockParentObjectFactory type]).andReturn(type);

    __block ALCMethodObjectFactory *internalMethodFactory;
    OCMExpect([_mockModel addObjectFactory:[OCMArg checkWithBlock:^BOOL(ALCMethodObjectFactory *methodFactory) {
        NSLog(@"Selector %@", NSStringFromSelector(methodFactory.selector));
        internalMethodFactory = methodFactory;
        return methodFactory.selector == @selector(description);
    }]
                                  withName:nil]);

    [_context objectFactory:mockParentObjectFactory
      registerFactoryMethod:@selector(description)
                 returnType:[NSString class], nil
     ];

    XCTAssertNotNil(internalMethodFactory);
    XCTAssertNotNil(internalMethodFactory.parentObjectFactory);
    XCTAssertEqual(mockParentObjectFactory, internalMethodFactory.parentObjectFactory);
    XCTAssertEqual(@selector(description), internalMethodFactory.selector);
    XCTAssertEqual(ALCFactoryTypeSingleton, internalMethodFactory.factoryType);

    OCMVerifyAll(mockParentObjectFactory);
    OCMVerifyAll(_mockModel);
}

-(void) testObjectFactoryRegisterFactoryMethodReturnTypeWithConfig {

    id mockParentObjectFactory = OCMProtocolMock(@protocol(ALCObjectFactory));
    ALCType *type = [ALCType typeWithClass:[NSString class]];
    OCMStub([(id<ALCObjectFactory>) mockParentObjectFactory type]).andReturn(type);

    __block ALCMethodObjectFactory *internalMethodFactory;
    OCMExpect([_mockModel addObjectFactory:[OCMArg checkWithBlock:^BOOL(ALCMethodObjectFactory *methodFactory) {
        NSLog(@"Selector %@", NSStringFromSelector(methodFactory.selector));
        internalMethodFactory = methodFactory;
        return methodFactory.selector == @selector(description);
    }]
                                  withName:nil]);

    [_context objectFactory:mockParentObjectFactory
      registerFactoryMethod:@selector(description)
                 returnType:[NSString class], AcTemplate, nil
     ];

    XCTAssertNotNil(internalMethodFactory);
    XCTAssertNotNil(internalMethodFactory.parentObjectFactory);
    XCTAssertEqual(mockParentObjectFactory, internalMethodFactory.parentObjectFactory);
    XCTAssertEqual(@selector(description), internalMethodFactory.selector);
    XCTAssertEqual(ALCFactoryTypeTemplate, internalMethodFactory.factoryType);

    OCMVerifyAll(mockParentObjectFactory);
    OCMVerifyAll(_mockModel);
}

-(void) testObjectFactoryRegisterFactoryMethodThrowsOnReferenceType {

    id mockParentObjectFactory = OCMProtocolMock(@protocol(ALCObjectFactory));
    ALCType *type = [ALCType typeWithClass:[NSString class]];
    OCMStub([(id<ALCObjectFactory>) mockParentObjectFactory type]).andReturn(type);

    XCTAssertThrowsSpecific(
                            ([_context objectFactory:mockParentObjectFactory registerFactoryMethod:@selector(description) returnType:[NSString class], AcReference, nil]),
                            AlchemicIllegalArgumentException);

}

@end
