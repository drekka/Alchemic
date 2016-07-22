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

@interface DummyDelegate : NSObject<UIApplicationDelegate>
@end

@implementation DummyDelegate
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

@interface ALCAbtractObjectFactoryTests : XCTestCase
@end

@implementation ALCAbtractObjectFactoryTests {
    ALCAbstractObjectFactory *_factory;
}

-(void)setUp {
    _factory = [[ALCAbstractObjectFactory alloc] initWithClass:[NSString class]];
}

-(void) testFactoryType {
    XCTAssertTrue(_factory.isReady);
}

-(void) testdefaultModelName {
    XCTAssertEqualObjects(@"NSString", _factory.defaultModelName);
}

-(void) testInitWithClass {
    XCTAssertEqual([NSString class], _factory.objectClass);
    XCTAssertEqual(ALCFactoryTypeSingleton, _factory.factoryType);
}

#pragma mark - Configuring

-(void) testConfigureWithOptions {
    id mockModel = OCMProtocolMock(@protocol(ALCModel));
    [_factory configureWithOptions:@[AcTemplate] model:mockModel];
    XCTAssertEqual(ALCFactoryTypeTemplate, _factory.factoryType);
}

-(void) testConfigureWithOptionTemplate {
    id mockModel = OCMProtocolMock(@protocol(ALCModel));
    [_factory configureWithOption:AcTemplate model:mockModel];
    XCTAssertEqual(ALCFactoryTypeTemplate, _factory.factoryType);
}

-(void) testConfigureWithOptionTemplateWeakThrows {
    id mockModel = OCMProtocolMock(@protocol(ALCModel));
    [_factory configureWithOption:AcWeak model:mockModel];
    XCTAssertThrowsSpecific(([_factory configureWithOption:AcTemplate model:mockModel]), AlchemicIllegalArgumentException);
}

-(void) testConfigureWithOptionReference {
    id mockModel = OCMProtocolMock(@protocol(ALCModel));
    [_factory configureWithOption:AcReference model:mockModel];
    XCTAssertEqual(ALCFactoryTypeReference, _factory.factoryType);
}

-(void) testConfigureWithOptionReferenceWeak {
    id mockModel = OCMProtocolMock(@protocol(ALCModel));
    [_factory configureWithOption:AcWeak model:mockModel];
    [_factory configureWithOption:AcReference model:mockModel];
    XCTAssertEqual(ALCFactoryTypeReference, _factory.factoryType);
    XCTAssertTrue(_factory.isWeak);
}

-(void) testConfigureWithOptionPrimary {
    id mockModel = OCMProtocolMock(@protocol(ALCModel));
    [_factory configureWithOption:AcPrimary model:mockModel];
    XCTAssertTrue(_factory.isPrimary);
}

-(void) testConfigureWithOptionFactoryName {
    id mockModel = OCMProtocolMock(@protocol(ALCModel));
    OCMExpect([mockModel reindexObjectFactoryOldName:@"NSString" newName:@"abc"]);
    [_factory configureWithOption:AcFactoryName(@"abc") model:mockModel];
    OCMVerifyAll(mockModel);
}

-(void) testConfigureWithOptionWeak {
    id mockModel = OCMProtocolMock(@protocol(ALCModel));
    [_factory configureWithOption:AcWeak model:mockModel];
    XCTAssertTrue(_factory.isWeak);
}

-(void) testConfigureWithOptionUnknownOptionThrows {
    id mockModel = OCMProtocolMock(@protocol(ALCModel));
    XCTAssertThrowsSpecific(([_factory configureWithOption:@"xxx" model:mockModel]), AlchemicIllegalArgumentException);
}

#pragma mark - Resolving

-(void) testResolveWithStackModel {
    NSMutableArray *stack = [[NSMutableArray alloc] init];
    id mockModel = OCMProtocolMock(@protocol(ALCModel));
    [_factory resolveWithStack:stack model:mockModel];
    // Does nothing so no validation.
}

#pragma mark - Creating things

-(void) testInstantiationWhenNoObject {
    DummyFactory *df = [[DummyFactory alloc] initWithClass:[NSString class]];
    ALCInstantiation *inst = df.instantiation;
    XCTAssertEqualObjects(@"abc", inst.object);
    [inst complete];
    XCTAssertTrue(df.completionCalled);
}

-(void) testInstantiationWhenObjectPresent {
    DummyFactory *df = [[DummyFactory alloc] initWithClass:[NSString class]];
    [df setObject:@"abc"];
    ALCInstantiation *inst = df.instantiation;
    XCTAssertEqualObjects(@"abc", inst.object);
    [inst complete];
    XCTAssertTrue(df.completionCalled);
}

#pragma mark - Describing things

-(void) testDescription {
    XCTAssertEqualObjects(@"  Singleton", [_factory description]);
}

-(void) testDescriptionWhenSet {
    DummyFactory *df = [[DummyFactory alloc] initWithClass:[NSString class]];
    [df setObject:@"abc"];
    XCTAssertEqualObjects(@"* Singleton", [df description]);
}

-(void) testDescriptionWhenReferenceNotSet {
    DummyFactory *df = [[DummyFactory alloc] initWithClass:[NSString class]];
    id mockModel = OCMProtocolMock(@protocol(ALCModel));
    [df configureWithOptions:@[AcReference] model:mockModel];
    XCTAssertEqualObjects(@"  Reference", [df description]);
}

-(void) testDescriptionWhenReferenceSet {
    DummyFactory *df = [[DummyFactory alloc] initWithClass:[NSString class]];
    id mockModel = OCMProtocolMock(@protocol(ALCModel));
    [df configureWithOptions:@[AcReference] model:mockModel];
    [df setObject:@"abc"];
    XCTAssertEqualObjects(@"* Reference", [df description]);
}

-(void) testDescriptionWhenUIApplicationDelegate {
    DummyFactory *df = [[DummyFactory alloc] initWithClass:[DummyDelegate class]];
    XCTAssertEqualObjects(@"  Singleton (App delegate)", [df description]);
}

@end
