//
//  ALCModelImplTests.m
//  Alchemic
//
//  Created by Derek Clarkson on 21/7/16.
//  Copyright © 2016 Derek Clarkson. All rights reserved.
//

@import XCTest;
@import Alchemic;
@import Alchemic.Private;
@import OCMock;

@interface FakeUIDelegate: NSObject<UIApplicationDelegate>
@end
@implementation FakeUIDelegate
@end

@interface ALCModelImplTests : XCTestCase
@end

@implementation ALCModelImplTests {
    id<ALCModel> _model;
    id<ALCObjectFactory> _classFactory;
    id<ALCObjectFactory> _referenceFactory;
    id<ALCObjectFactory> _methodFactory;
}

-(void)setUp {

    _model = [[ALCModelImpl alloc] init];
    
    _classFactory = [[ALCClassObjectFactory alloc] initWithClass:[NSString class]];
    [_model addObjectFactory:_classFactory withName:nil];
    
    _referenceFactory = [[ALCClassObjectFactory alloc] initWithClass:[NSString class]];
    [_methodFactory configureWithOptions:@[AcReference] model:_model];
    [_model addObjectFactory:_referenceFactory withName:@"ref"];
    
    _methodFactory = [[ALCMethodObjectFactory alloc] initWithClass:[NSString class]
                                               parentObjectFactory:_classFactory
                                                          selector:@selector(description)
                                                              args:nil];
    [_methodFactory configureWithOptions:@[AcTemplate] model:_model];
    [_model addObjectFactory:_methodFactory withName:@"abc"];
}

-(void) testObjectFactories {
    NSArray<id<ALCObjectFactory>> *factories = _model.objectFactories;
    XCTAssertEqual(3u, factories.count);
    XCTAssertTrue([factories containsObject:_classFactory]);
    XCTAssertTrue([factories containsObject:_referenceFactory]);
    XCTAssertTrue([factories containsObject:_methodFactory]);
}

-(void) testClassObjectFactories {
    NSArray<id<ALCObjectFactory>> *factories = _model.classObjectFactories;
    XCTAssertEqual(2u, factories.count);
    XCTAssertTrue([factories containsObject:_classFactory]);
    XCTAssertTrue([factories containsObject:_referenceFactory]);
}

-(void) testClassObjectFactoryForClass {
    id<ALCObjectFactory> of = [_model classObjectFactoryForClass:[NSString class]];
    XCTAssertEqual(_classFactory, of);
}

-(void) testClassObjectFactoryForClassWhenNotFound {
    XCTAssertNil([_model classObjectFactoryForClass:[NSDate class]]);
}

-(void) testObjectFactoriesMatchingCriteria {
    NSArray<id<ALCObjectFactory>> *factories = [_model objectFactoriesMatchingCriteria:AcName(@"abc")];
    XCTAssertEqual(1u, factories.count);
    XCTAssertTrue([factories containsObject:_methodFactory]);
}

-(void) testObjectFactoriesMatchingCriteriaNoMatch {
    NSArray<id<ALCObjectFactory>> *factories = [_model objectFactoriesMatchingCriteria:AcName(@"def")];
    XCTAssertNotNil(factories);
    XCTAssertEqual(0u, factories.count);
}

-(void) testSettableObjectFactoriesMatchingCriteria {
    NSArray<id<ALCObjectFactory>> *factories = [_model settableObjectFactoriesMatchingCriteria:AcClass(NSString)];
    XCTAssertEqual(2u, factories.count);
    XCTAssertTrue([factories containsObject:_classFactory]);
    XCTAssertTrue([factories containsObject:_referenceFactory]);
}

-(void) testAddObjectFactoryWithNameThrowsOnDuplicateName {
    // Happy path already tested in setup.
    XCTAssertThrowsSpecific(([_model addObjectFactory:[[ALCClassObjectFactory alloc] initWithClass:[NSString class]] withName:@"abc"]), AlchemicDuplicateNameException);
}

-(void) testReindexObjectFactoryOldNameNewName {
    [_model reindexObjectFactoryOldName:@"abc" newName:@"xyz"];
    NSArray<id<ALCObjectFactory>> *factories = [_model objectFactoriesMatchingCriteria:AcName(@"xyz")];
    XCTAssertEqual(1u, factories.count);
    XCTAssertTrue([factories containsObject:_methodFactory]);
}

-(void) testResolveDependencies {

    _model = [[ALCModelImpl alloc] init];
    id classFactoryMock = OCMClassMock([ALCClassObjectFactory class]);
    [_model addObjectFactory:classFactoryMock withName:@"abc"];

    OCMStub([classFactoryMock conformsToProtocol:@protocol(UIApplicationDelegate)]).andReturn(NO);
    OCMExpect([classFactoryMock resolveWithStack:[OCMArg isKindOfClass:[NSMutableArray class]] model:_model]);
    
    [_model resolveDependencies];
    
    OCMVerifyAll(classFactoryMock);
}

-(void) testStartSingletons {

    _model = [[ALCModelImpl alloc] init];
    id classFactoryMock = OCMClassMock([ALCClassObjectFactory class]);
    [_model addObjectFactory:classFactoryMock withName:@"abc"];
    
    OCMExpect([classFactoryMock factoryType]).andReturn(ALCFactoryTypeSingleton);
    OCMExpect([classFactoryMock isReady]).andReturn(YES);
    OCMStub([classFactoryMock objectClass]).andReturn([NSObject class]);
    OCMStub([classFactoryMock description]).andReturn(@"singelton abc");

    id instantiationMock = OCMClassMock([ALCInstantiation class]);
    OCMExpect([classFactoryMock instantiation]).andReturn(instantiationMock);
    OCMExpect([instantiationMock object]).andReturn(@"xyz");
    OCMExpect([instantiationMock complete]);
    
    [_model startSingletons];
    
    OCMVerifyAll(classFactoryMock);
    OCMVerifyAll(instantiationMock);
}

-(void) testStartSingletonsWithUIApplicationDelegate {
    // This is rather tricky to mock out or test. So not doing it ATM.
}

-(void) testDescription {
    NSString *desc = _model.description;
    XCTAssertTrue([desc containsString:@"Finished model (* - instantiated):"]);
    XCTAssertTrue([desc containsString:@"Singleton class NSString, as 'NSString'"]);
    XCTAssertTrue([desc containsString:@"Singleton class NSString, as 'ref'"]);
    XCTAssertTrue([desc containsString:@"Template method +[NSString description] -> NSString, as 'abc'"]);
}

@end
