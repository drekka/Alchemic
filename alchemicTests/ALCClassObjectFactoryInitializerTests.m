//
//  ALCClassObjectFactoryInitializerTests.m
//  Alchemic
//
//  Created by Derek Clarkson on 5/07/2016.
//  Copyright © 2016 Derek Clarkson. All rights reserved.
//

@import XCTest;
@import OCMock;
@import Alchemic;
@import Alchemic.Private;

@interface ALCClassObjectFactoryInitializerTests : XCTestCase

@end

@implementation ALCClassObjectFactoryInitializerTests {
    ALCClassObjectFactoryInitializer *_initializer;
}

#pragma mark - Test initializers

-(instancetype) init {
    self = [super init];
    return self;
}

-(instancetype) initWithArg:(id) arg {
    self = [super init];
    return self;
}

-(void)setUp {
    id mockObjectFactory = OCMClassMock([ALCClassObjectFactory class]);
    ALCType *type = [ALCType typeWithClass:[ALCClassObjectFactoryInitializerTests class]];
    OCMStub([(id<ALCObjectFactory>) mockObjectFactory type]).andReturn(type);
    OCMExpect([mockObjectFactory setInitializer:[OCMArg checkWithBlock:^BOOL(id obj) {
        return [obj isKindOfClass:[ALCClassObjectFactoryInitializer class]];
    }]]);
    _initializer = [[ALCClassObjectFactoryInitializer alloc] initWithObjectFactory:mockObjectFactory
                                                                       initializer:@selector(init)
                                                                              args:nil];

}

#pragma mark - Tests

-(void) testInitWithObjectInitializerArgs {
    [self setUpWithInitializer:@selector(init) args:nil];
    XCTAssertEqual([ALCClassObjectFactoryInitializerTests class], _initializer.type.objcClass);
    XCTAssertEqual(@selector(init), _initializer.initializer);
}

-(void) testResolveWithStackModel {
    [self setUpWithInitializer:@selector(init) args:nil];
    id mockModel = OCMProtocolMock(@protocol(ALCModel));
    NSMutableArray *stack = [[NSMutableArray alloc] init];
    [_initializer resolveWithStack:stack model:mockModel];
    // Nothing to check here.
}

-(void) testResolveWithStackModelCallsResolveOnArgs {
    id mockArg = OCMProtocolMock(@protocol(ALCDependency));
    [self setUpWithInitializer:@selector(initWithArg:) args:@[mockArg]];
    id mockModel = OCMProtocolMock(@protocol(ALCModel));

    NSMutableArray *stack = [[NSMutableArray alloc] init];
    [_initializer resolveWithStack:stack model:mockModel];

    OCMVerifyAll(mockArg);
}

-(void) testCreateObject {
    [self setUpWithInitializer:@selector(init) args:nil];
    id obj = [_initializer createObject];
    XCTAssertNotNil(obj);
    XCTAssertTrue([obj isKindOfClass:[ALCClassObjectFactoryInitializerTests class]]);
}

-(void) testObjectCompletion {
    [self setUpWithInitializer:@selector(init) args:nil];
    XCTAssertNil([_initializer objectCompletion]);
}

-(void) testdefaultModelName {
    [self setUpWithInitializer:@selector(init) args:nil];
    XCTAssertEqualObjects(@"+[ALCClassObjectFactoryInitializerTests init]", [_initializer defaultModelName]);
}

-(void) testDescription {
    [self setUpWithInitializer:@selector(init) args:nil];
    XCTAssertEqualObjects(@"initializer +[ALCClassObjectFactoryInitializerTests init]", [_initializer description]);
}

-(void) testResolvingDescription {
    [self setUpWithInitializer:@selector(init) args:nil];
    XCTAssertEqualObjects(@"initializer +[ALCClassObjectFactoryInitializerTests init]", [_initializer description]);
}

-(void) testReadyWithNoArguments {
    [self setUpWithInitializer:@selector(init) args:nil];
    XCTAssertTrue(_initializer.isReady);
}

-(void) testReadyWithArgumentsReady {
    id mockArg = OCMProtocolMock(@protocol(ALCDependency));
    OCMStub([mockArg isReady]).andReturn(YES);
    [self setUpWithInitializer:@selector(initWithArg:) args:@[mockArg]];
    XCTAssertTrue(_initializer.isReady);
}

-(void) testReadyWithArgumentsNotReady {
    id mockArg = OCMProtocolMock(@protocol(ALCDependency));
    OCMStub([mockArg isReady]).andReturn(NO);
    [self setUpWithInitializer:@selector(initWithArg:) args:@[mockArg]];
    XCTAssertFalse(_initializer.isReady);
}

#pragma mark - Internal

-(void) setUpWithInitializer:(SEL) initializer args:(NSArray *) args {
    id mockObjectFactory = OCMClassMock([ALCClassObjectFactory class]);
    ALCType *type = [ALCType typeWithClass:[ALCClassObjectFactoryInitializerTests class]];
    OCMStub([(id<ALCObjectFactory>) mockObjectFactory type]).andReturn(type);
    OCMExpect([mockObjectFactory setInitializer:[OCMArg checkWithBlock:^BOOL(id obj) {
        return [obj isKindOfClass:[ALCClassObjectFactoryInitializer class]];
    }]]);
    _initializer = [[ALCClassObjectFactoryInitializer alloc] initWithObjectFactory:mockObjectFactory
                                                                       initializer:initializer
                                                                              args:args];
}



@end
