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

#import "TopThing.h"
#import "XCTestCase+Alchemic.h"

@interface ALCContextImplTests : XCTestCase

@end

@implementation ALCContextImplTests {
    NSObject<ALCContext> *_context;
    id _mockModel;
}

- (void)setUp {
    _context = [[ALCContextImpl alloc] init];
    _mockModel = OCMClassMock([ALCModelImpl class]);
    [self setVariable:@"_model" inObject:_context value:_mockModel];
}

#pragma mark - Startup

-(void) testStart {
    OCMExpect([_mockModel resolveDependencies]);
    OCMExpect([_mockModel startSingletons]);
    
    [self expectationForNotification:AlchemicDidFinishStarting object:_context handler:nil];
    
    [_context start];
    
    [self waitForExpectationsWithTimeout:0.5 handler:nil];
    
    OCMVerifyAll(_mockModel);
}

#pragma mark - ExecuteBlockWhenStarted

-(void) testExecuteBlockWhenStartedBeforeStartupFinished {
    
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

-(void) testExecuteBlockWhenStartedAfterStartupFinished {
    
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

#pragma mark - Adding resolve aspects

-(void) testAddResolveAspect {
    id mockAspect = OCMProtocolMock(@protocol(ALCResolveAspect));
    OCMExpect([_mockModel addResolveAspect:mockAspect]);
    [_context addResolveAspect:mockAspect];
    OCMVerifyAll(_mockModel);
}

#pragma mark - Registering class object factories

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

#pragma mark - Registering method object factories

-(void) testObjectFactoryRegisterFactoryMethodReturnType {
    
    id mockParentObjectFactory = [self mockParentObjectFactoryOfType:ALCFactoryTypeSingleton forClass:[NSString class]];
    
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
    
    id mockParentObjectFactory = [self mockParentObjectFactoryOfType:ALCFactoryTypeSingleton forClass:[NSString class]];
    
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

-(void) testObjectFactoryRegisterFactoryMethodReturnTypeThrowsOnReferenceType {
    
    id mockParentObjectFactory = [self mockParentObjectFactoryOfType:ALCFactoryTypeSingleton forClass:[NSString class]];
    
    XCTAssertThrowsSpecific(
                            ([_context objectFactory:mockParentObjectFactory registerFactoryMethod:@selector(description) returnType:[NSString class], AcReference, nil]),
                            AlchemicIllegalArgumentException
                            );
}

#pragma mark - Registering class factory initializers

-(void) testObjectFactoryInitializer {
    
    id mockParentObjectFactory = [self mockParentObjectFactoryOfType:ALCFactoryTypeSingleton forClass:[NSString class]];
    
    __block ALCClassObjectFactoryInitializer *initializer;
    OCMExpect([(ALCClassObjectFactory *) mockParentObjectFactory setInitializer:[OCMArg checkWithBlock:^BOOL(id obj) {
        XCTAssertTrue([obj isKindOfClass:[ALCClassObjectFactoryInitializer class]]);
        initializer = obj;
        return YES;
    }]]);
    
    [_context objectFactory:mockParentObjectFactory initializer:@selector(init), nil];
    
    XCTAssertEqual(@selector(init), initializer.initializer);
    OCMVerifyAll(mockParentObjectFactory);
    
}
-(void) testObjectFactoryInitializerThrowsWhenParentIsReference {
    
    id mockParentObjectFactory = [self mockParentObjectFactoryOfType:ALCFactoryTypeReference forClass:[NSString class]];
    
    XCTAssertThrowsSpecific(([_context objectFactory:mockParentObjectFactory initializer:@selector(init), nil]), AlchemicIllegalArgumentException);
}

-(void) testObjectFactoryInitializerWithArgs {
    
    id mockParentObjectFactory = [self mockParentObjectFactoryOfType:ALCFactoryTypeSingleton forClass:[NSString class]];
    
    __block ALCClassObjectFactoryInitializer *initializer;
    OCMExpect([(ALCClassObjectFactory *) mockParentObjectFactory setInitializer:[OCMArg checkWithBlock:^BOOL(id obj) {
        XCTAssertTrue([obj isKindOfClass:[ALCClassObjectFactoryInitializer class]]);
        initializer = obj;
        return YES;
    }]]);
    
    [_context objectFactory:mockParentObjectFactory initializer:@selector(initWithString:), AcString(@"abc"), nil];
    
    XCTAssertEqual(@selector(initWithString:), initializer.initializer);
    OCMVerifyAll(mockParentObjectFactory);
    
    id result = [initializer createObject];
    XCTAssertEqualObjects(@"abc", result);
    
}

-(void) testObjectFactoryInitializerWithArgsThrowsWhenOtherArg {
    
    id mockParentObjectFactory = [self mockParentObjectFactoryOfType:ALCFactoryTypeSingleton forClass:[NSString class]];
    
    XCTAssertThrowsSpecific(([_context objectFactory:mockParentObjectFactory initializer:@selector(initWithString:), AcReference, nil]), AlchemicIllegalArgumentException);
}

#pragma mark - Registering injections

-(void) testObjectFactoryRegisterInjection {
    
    id mockParentObjectFactory = [self mockParentObjectFactoryOfType:ALCFactoryTypeSingleton forClass:[TopThing class]];
    
    id<ALCValueSource> intValueSource = AcInt(5);
    id mockDependency = OCMClassMock([ALCVariableDependency class]);
    OCMExpect([[mockParentObjectFactory ignoringNonObjectArgs] registerVariableDependency:NULL // Note OCMock cannot handle primitives like these.
                                                                                     type:[OCMArg checkWithBlock:^BOOL(ALCType *type) {
        XCTAssertTrue(type.type == ALCValueTypeInt);
        return YES;
    }]
                                                                              valueSource:intValueSource
                                                                                 withName:@"aInt"]).andReturn(mockDependency);
    
    OCMExpect([mockDependency configureWithOptions:[OCMArg checkWithBlock:^BOOL(NSArray *options) {
        return YES;
    }]]);
    
    [_context objectFactory:mockParentObjectFactory registerInjection: @"aInt", intValueSource, nil];
    
    OCMVerifyAll(mockParentObjectFactory);
    OCMVerifyAll(mockDependency);
    
}

#pragma mark - Getting and setting

-(void) testObjectWithClassSearchCriteriaThrowsWhenAlchemicNotReady {
    XCTAssertThrowsSpecific(([_context objectWithClass:[NSString class], nil]), AlchemicLifecycleException);
}

-(void) testObjectWithClassSearchCriteriaThrowsWhenIllegalArgument {

    // Tell the context it's started
    [self setVariable:@"_postStartBlocks" inObject:_context value:nil];

    XCTAssertThrowsSpecific(([_context objectWithClass:[NSString class], @"abc", nil]), AlchemicIllegalArgumentException);
}

-(void) testObjectWithClassSearchCriteriaThrowsMappingException {

    // Tell the context it's started
    [self setVariable:@"_postStartBlocks" inObject:_context value:nil];

    // Mock out value source creation.
    id mockValueSource = OCMClassMock([ALCModelValueSource class]);
    OCMStub(ClassMethod([mockValueSource valueSourceWithCriteria:OCMOCK_ANY])).andReturn(mockValueSource);

    // Mock resolving the model.
    id mockFactory = OCMProtocolMock(@protocol(ALCObjectFactory));
    OCMStub([_mockModel objectFactoriesMatchingCriteria:OCMOCK_ANY]).andReturn(@[mockFactory]);

    // ANd return a non-matching value.
    ALCValue *value = [[ALCType typeWithClass:[NSString class]] withValue:@"abc" completion:NULL];
    OCMStub([mockValueSource valueWithError:[OCMArg anyObjectRef]]).andReturn(value);

    XCTAssertThrowsSpecific(([_context objectWithClass:[NSNumber class], nil]), AlchemicMappingValueException);
}

-(void) testObjectWithClassSearchCriteria {

    // Tell the context it's started
    [self setVariable:@"_postStartBlocks" inObject:_context value:nil];

    // Mock out value source creation.
    id mockValueSource = OCMClassMock([ALCModelValueSource class]);
    OCMStub(ClassMethod([mockValueSource valueSourceWithCriteria:OCMOCK_ANY])).andReturn(mockValueSource);

    // Mock resolving the model.
    id mockFactory = OCMProtocolMock(@protocol(ALCObjectFactory));
    OCMStub([_mockModel objectFactoriesMatchingCriteria:OCMOCK_ANY]).andReturn(@[mockFactory]);

    // ANd return a non-matching value.
    ALCValue *value = [[ALCType typeWithClass:[NSNumber class]] withValue:@5 completion:NULL];
    OCMStub([mockValueSource valueWithError:[OCMArg anyObjectRef]]).andReturn(value);

    NSNumber *result = [_context objectWithClass:[NSNumber class], nil];
    XCTAssertEqualObjects(@5, result);
}

#pragma mark - Internal

-(id) mockParentObjectFactoryOfType:(ALCFactoryType) type forClass:(Class) forClass {
    
    id mockParentObjectFactory = OCMClassMock([ALCClassObjectFactory class]);
    OCMStub([mockParentObjectFactory factoryType]).andReturn(type);
    
    ALCType *alcType = [ALCType typeWithClass:forClass];
    OCMStub([(id<ALCObjectFactory>) mockParentObjectFactory type]).andReturn(alcType);
    return mockParentObjectFactory;
}

@end
