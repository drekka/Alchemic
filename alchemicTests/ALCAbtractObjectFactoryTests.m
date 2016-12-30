//
//  ALCAbtractObjectFactoryTests.m
//  Alchemic
//
//  Created by Derek Clarkson on 6/07/2016.
//  Copyright © 2016 Derek Clarkson. All rights reserved.
//

@import XCTest;
@import Alchemic;
@import Alchemic.Private;
@import OCMock;

#pragma mark - Test classes

@interface DummyAppDelegate : NSObject<UIApplicationDelegate>
@end

@implementation DummyAppDelegate
@end

@interface DummyFactory : ALCAbstractObjectFactory
@property (nonatomic, assign, readonly) BOOL completionCalled;
@end

@implementation DummyFactory
-(id) createObject {
    return @"abc";
}

-(ALCBlockWithObject) objectCompletion {
    return ^(ALCBlockWithObjectArgs) {
        self->_completionCalled = YES;
    };
}

@end

#pragma mark - Tests

@interface ALCAbtractObjectFactoryTests : XCTestCase
@end

@implementation ALCAbtractObjectFactoryTests {
    ALCAbstractObjectFactory *_factory;
    id _mockModel;
}

-(void)setUp {
    _mockModel = OCMProtocolMock(@protocol(ALCModel));
    _factory = [[ALCAbstractObjectFactory alloc] initWithType:[ALCType typeWithClass:[NSString class]]];
}

-(void) testFactoryType {
    XCTAssertTrue(_factory.isReady);
}

-(void) testIsWeak {
    [_factory configureWithOptions:@[AcWeak] model:_mockModel];
    XCTAssertTrue(_factory.isWeak);
}

-(void) testDefaultModelName {
    XCTAssertEqualObjects(@"NSString", _factory.defaultModelName);
}

-(void) testInitWithClass {
    XCTAssertEqual([NSString class], _factory.type.objcClass);
    XCTAssertEqual(ALCFactoryTypeSingleton, _factory.factoryType);
}

#pragma mark - Configuring

-(void) testConfigureWithOptions {
    [_factory configureWithOptions:@[AcTemplate] model:_mockModel];
    XCTAssertEqual(ALCFactoryTypeTemplate, _factory.factoryType);
}

-(void) testConfigureWithOptionTemplate {
    [_factory configureWithOption:AcTemplate model:_mockModel];
    XCTAssertEqual(ALCFactoryTypeTemplate, _factory.factoryType);
}

-(void) testConfigureWithOptionTemplateWeakThrows {
    [_factory configureWithOption:AcWeak model:_mockModel];
    XCTAssertThrowsSpecific(([_factory configureWithOption:AcTemplate model:_mockModel]), AlchemicIllegalArgumentException);
}

-(void) testConfigureWithOptionReference {
    [_factory configureWithOption:AcReference model:_mockModel];
    XCTAssertEqual(ALCFactoryTypeReference, _factory.factoryType);
}

-(void) testConfigureWithOptionReferenceWeak {
    [_factory configureWithOption:AcWeak model:_mockModel];
    [_factory configureWithOption:AcReference model:_mockModel];
    XCTAssertEqual(ALCFactoryTypeReference, _factory.factoryType);
    XCTAssertTrue(_factory.isWeak);
}

-(void) testConfigureWithOptionPrimary {
    [_factory configureWithOption:AcPrimary model:_mockModel];
    XCTAssertTrue(_factory.isPrimary);
}

-(void) testConfigureWithOptionFactoryName {
    OCMExpect([_mockModel reindexObjectFactoryOldName:@"NSString" newName:@"abc"]);
    [_factory configureWithOption:AcFactoryName(@"abc") model:_mockModel];
    OCMVerifyAll(_mockModel);
}

-(void) testConfigureWithOptionWeak {
    [_factory configureWithOption:AcWeak model:_mockModel];
    XCTAssertTrue(_factory.isWeak);
    XCTAssertFalse(_factory.isNillable);
}

-(void) testConfigureWithOptionNillable {
    [_factory configureWithOption:AcNillable model:_mockModel];
    XCTAssertTrue(_factory.isNillable);
    XCTAssertFalse(_factory.isWeak);
}

-(void) testConfigureWithOptionUnknownOptionThrows {
    XCTAssertThrowsSpecific(([_factory configureWithOption:@"xxx" model:_mockModel]), AlchemicIllegalArgumentException);
}

#pragma mark - Resolving

-(void) testResolveWithStackModel {
    NSMutableArray *stack = [[NSMutableArray alloc] init];
    [_factory resolveWithStack:stack model:_mockModel];
    // Does nothing so no validation.
}

#pragma mark - Creating things

-(void) testInstantiationWhenNoObject {
    ALCType *type = [ALCType typeWithClass:[NSString class]];
    DummyFactory *df = [[DummyFactory alloc] initWithType:type];
    ALCValue *value = df.value;
    XCTAssertEqualObjects(@"abc", value.object);
    [value complete];
    XCTAssertTrue(df.completionCalled);
}

-(void) testInstantiationWhenObjectPresent {
    ALCType *type = [ALCType typeWithClass:[NSString class]];
    DummyFactory *df = [[DummyFactory alloc] initWithType:type];
    [df storeObject:@"abc"];
    ALCValue *value = df.value;
    XCTAssertEqualObjects(@"abc", value.object);
    [value complete];
    XCTAssertTrue(df.completionCalled);
}

#pragma mark - Storing values

-(void) testSetObject {
    ALCType *type = [ALCType typeWithClass:[NSString class]];
    DummyFactory *df = [[DummyFactory alloc] initWithType:type];
    [df storeObject:@"abc"];
    XCTAssertEqualObjects(@"abc", df.value.object);
}

-(void) testSetObjectPostNotification {

    ALCType *type = [ALCType typeWithClass:[NSString class]];
    DummyFactory *df = [[DummyFactory alloc] initWithType:type];
    
    [self expectationForNotification:AlchemicDidStoreObject
                              object:df
                             handler:nil];
    [df storeObject:@"abc"];

    [self waitForExpectationsWithTimeout:0.3 handler:nil];

}

#pragma mark - Describing things

-(void) testDescription {
    XCTAssertEqualObjects(@"[ S    ", [_factory description]);
}

-(void) testDescriptionWhenSet {
    ALCType *type = [ALCType typeWithClass:[NSString class]];
    DummyFactory *df = [[DummyFactory alloc] initWithType:type];
    [df storeObject:@"abc"];
    XCTAssertEqualObjects(@"[*S    ", [df description]);
}

-(void) testDescriptionWhenReferenceNotSet {
    ALCType *type = [ALCType typeWithClass:[NSString class]];
    DummyFactory *df = [[DummyFactory alloc] initWithType:type];
    [df configureWithOptions:@[AcReference] model:_mockModel];
    XCTAssertEqualObjects(@"[  R   ", [df description]);
}

-(void) testDescriptionWhenReferenceSet {
    ALCType *type = [ALCType typeWithClass:[NSString class]];
    DummyFactory *df = [[DummyFactory alloc] initWithType:type];
    [df configureWithOptions:@[AcReference] model:_mockModel];
    [df storeObject:@"abc"];
    XCTAssertEqualObjects(@"[* R   ", [df description]);
}

-(void) testDescriptionWhenUIApplicationDelegate {
    ALCType *type = [ALCType typeWithClass:[DummyAppDelegate class]];
    DummyFactory *df = [[DummyFactory alloc] initWithType:type];
    XCTAssertEqualObjects(@"[ S    ", [df description]);
}

@end
