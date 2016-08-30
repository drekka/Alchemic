//
//  ALCClassObjectFactoryTests.m
//  Alchemic
//
//  Created by Derek Clarkson on 24/7/16.
//  Copyright © 2016 Derek Clarkson. All rights reserved.
//

@import XCTest;
@import Alchemic;
@import Alchemic.Private;
@import OCMock;
@import ObjectiveC;

@interface ALCClassObjectFactoryTests : XCTestCase
@end

@implementation ALCClassObjectFactoryTests {
    ALCClassObjectFactory *_factory;
    id _mockModel;
}

-(void)setUp {
    ALCType *type = [ALCType typeWithClass:[NSString class]];
    _factory = [[ALCClassObjectFactory alloc] initWithType:type];
    _mockModel = OCMProtocolMock(@protocol(ALCModel));
}

-(void) testConfigureWithOptionModelSuperCall {
    [_factory configureWithOption:AcNillable model:_mockModel];
    XCTAssertTrue(_factory.isNillable);
}

-(void) testConfigureWithOptionModelReference {
    [_factory configureWithOption:AcReference model:_mockModel];
    XCTAssertEqual(ALCFactoryTypeReference, _factory.factoryType);
}

-(void) testResolveWithStackModelThrowsWhenIncorrectConfig {

    // Setup initializer on reference factory.
    [_factory configureWithOption:AcReference model:_mockModel];
    __unused id _ = [[ALCClassObjectFactoryInitializer alloc] initWithObjectFactory:_factory initializer:@selector(init) args:nil];

    NSMutableArray *stack = [[NSMutableArray alloc] init];
    XCTAssertThrowsSpecific([_factory resolveWithStack:stack model:_mockModel], AlchemicIllegalArgumentException);
}

-(void) testResolveWithStackModelResolvesInitializer {

    NSMutableArray *stack = [[NSMutableArray alloc] init];

    // Setup initializer on reference factory.
    id mockInitializer = OCMClassMock([ALCClassObjectFactoryInitializer class]);
    OCMExpect([mockInitializer resolveWithStack:stack model:_mockModel]);

    [_factory resolveWithStack:stack model:_mockModel];

    OCMVerify(mockInitializer);
}

-(void) testResolveWithStackModelResolvesDependencies {

    NSMutableArray *stack = [[NSMutableArray alloc] init];
    id mockValueSource = OCMProtocolMock(@protocol(ALCValueSource));
    OCMExpect([mockValueSource resolveWithStack:stack model:_mockModel]);

    Ivar ivar = class_getInstanceVariable([self class], "_mockModel");
    __unused id _ = [_factory registerVariableDependency:ivar
                                                    type:[ALCType typeWithClass:[ALCModelImpl class]]
                                                valueSource:mockValueSource
                                                withName:@"mockModel"];

    [_factory resolveWithStack:stack model:_mockModel];

    OCMVerifyAll(mockValueSource);
}

@end
