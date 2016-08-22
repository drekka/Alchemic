//
//  ALCModelObjectInjectorTests.m
//  Alchemic
//
//  Created by Derek Clarkson on 15/8/16.
//  Copyright © 2016 Derek Clarkson. All rights reserved.
//

@import XCTest;
@import Alchemic;
@import Alchemic.Private;
@import OCMock;

#import "XCTestCase+Alchemic.h"

@interface ALCModelObjectInjectorTests : XCTestCase

@end

@implementation ALCModelObjectInjectorTests {
    ALCModelObjectInjector *_injector;
    ALCModelSearchCriteria *_criteria;
    NSString *_injectedValue;
}

-(void)setUp {
    _criteria = AcClass(NSString);
    _injector = [[ALCModelObjectInjector alloc] initWithObjectClass:[NSString class] criteria:_criteria];
}

-(void) testInitWithObjectClassCriteria {
    XCTAssertEqual([NSString class], _injector.objectClass);
    ALCModelSearchCriteria *injCriteria = _injector.criteria;
    XCTAssertEqualObjects(@"class NSString", injCriteria.description);
}

-(void) testIsReadyWhenFactoriesReady {
    id<ALCObjectFactory> factory = OCMProtocolMock(@protocol(ALCObjectFactory));
    OCMStub([factory isReady]).andReturn(YES);

    [self setVariable:@"_resolvedFactories" inObject:_injector value:@[factory]];

    XCTAssertTrue(_injector.isReady);
}

-(void) testIsReadyWhenFactoriesNotReady {
    id<ALCObjectFactory> factory = OCMProtocolMock(@protocol(ALCObjectFactory));
    OCMStub([factory isReady]).andReturn(NO);

    [self setVariable:@"_resolvedFactories" inObject:_injector value:@[factory]];

    XCTAssertFalse(_injector.isReady);
}

-(void) testIsReadyWhenNoFactories {
    [self setVariable:@"_resolvedFactories" inObject:_injector value:@[]];
    XCTAssertFalse(_injector.isReady);
}

-(void) testResolveWithStackModel {

    id mockModel = OCMProtocolMock(@protocol(ALCModel));
    NSMutableArray *stack = [[NSMutableArray alloc] init];

    id mockFactory = OCMProtocolMock(@protocol(ALCObjectFactory));

    OCMStub([mockModel objectFactoriesMatchingCriteria:_criteria]).andReturn(@[mockFactory]);

    OCMStub([mockFactory isPrimary]).andReturn(NO);
    OCMExpect([mockFactory resolveWithStack:stack model:mockModel]);

    [_injector resolveWithStack:stack model:mockModel];

    NSArray *factories = [self getVariable:@"_resolvedFactories" fromObject:_injector];

    XCTAssertEqual(1u, factories.count);
    XCTAssertEqual(mockFactory, factories[0]);
}

-(void) testResolveWithStackModelFindsNothing {

    id mockModel = OCMProtocolMock(@protocol(ALCModel));
    NSMutableArray *stack = [[NSMutableArray alloc] init];

    OCMStub([mockModel objectFactoriesMatchingCriteria:_criteria]).andReturn(@[]);

    XCTAssertThrowsSpecific([_injector resolveWithStack:stack model:mockModel], AlchemicNoDependenciesFoundException);
}

-(void) testResolveWithStackModelWhenPrimaryPresent {

    id mockModel = OCMProtocolMock(@protocol(ALCModel));
    NSMutableArray *stack = [[NSMutableArray alloc] init];

    id mockFactory1 = OCMProtocolMock(@protocol(ALCObjectFactory));
    id mockFactory2 = OCMProtocolMock(@protocol(ALCObjectFactory));

    NSArray *foundFactories = @[mockFactory1, mockFactory2];
    OCMStub([mockModel objectFactoriesMatchingCriteria:_criteria]).andReturn(foundFactories);

    OCMStub([mockFactory1 isPrimary]).andReturn(YES);
    OCMExpect([mockFactory1 resolveWithStack:stack model:mockModel]);

    OCMStub([mockFactory2 isPrimary]).andReturn(NO);

    [_injector resolveWithStack:stack model:mockModel];

    NSArray *factories = [self getVariable:@"_resolvedFactories" fromObject:_injector];

    XCTAssertEqual(1u, factories.count);
    XCTAssertEqual(mockFactory1, factories[0]);
}

-(void) testReferencesObjectFactory {
    id mockFactory = OCMProtocolMock(@protocol(ALCObjectFactory));
    [self setVariable:@"_resolvedFactories" inObject:_injector value:@[mockFactory]];
    XCTAssertTrue([_injector referencesObjectFactory:mockFactory]);
}

-(void) testResolvingDescription {
    XCTAssertThrows([_injector resolvingDescription]);
}

-(void) testSetObjectVariableError {

    id mockFactory = OCMProtocolMock(@protocol(ALCObjectFactory));

    __block BOOL completionCalled;
    ALCInstantiation *instantiation = [ALCInstantiation instantiationWithObject:@"abc" completion:^(id obj){
        completionCalled = YES;
    }];

    OCMStub([mockFactory instantiation]).andReturn(instantiation);

    [self setVariable:@"_resolvedFactories" inObject:_injector value:@[mockFactory]];

    Ivar variable = class_getInstanceVariable([self class], "_injectedValue");
    NSError *error;
    ALCSimpleBlock completion = [_injector setObject:self variable:variable error:&error];
    
    XCTAssertEqualObjects(@"abc", _injectedValue);

    completion();
    XCTAssertTrue(completionCalled);

}

-(void) testSetInvocationArgumentIndexError {

    id mockFactory = OCMProtocolMock(@protocol(ALCObjectFactory));

    __block BOOL completionCalled;
    ALCInstantiation *instantiation = [ALCInstantiation instantiationWithObject:@"abc" completion:^(id obj){
        completionCalled = YES;
    }];

    OCMStub([mockFactory instantiation]).andReturn(instantiation);

    [self setVariable:@"_resolvedFactories" inObject:_injector value:@[mockFactory]];

    NSMethodSignature *sig = [NSMethodSignature methodSignatureForSelector:@selector(setSomeString:)];
    NSInvocation *inv = [NSInvocation invocationWithMethodSignature:sig];

    NSError *error;
    BOOL injected = [_injector setInvocation:inv argumentIndex:2 error:&error];

    XCTAssertTrue(injected);
    XCTAssertTrue(completionCalled);
    
}

#pragma mark - Internal

-(void) setSomeString:(NSString *) aString {}


@end
