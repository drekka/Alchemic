//
//  InjectByMatcherTests.m
//  alchemic
//
//  Created by Derek Clarkson on 30/03/2015.
//  Copyright (c) 2015 Derek Clarkson. All rights reserved.
//

#import "ALCTestCase.h"
#import <Alchemic/Alchemic.h>
#import <StoryTeller/StoryTeller.h>
#import <OCMock/OCMock.h>
#import "SingletonObject.h"
#import "InjectableProtocol.h"

@import XCTest;

@interface InjectionTests : ALCTestCase
@end

@implementation InjectionTests {
    id _singletonObjectByName;
    id _singletonObjectByClass;
    id _singletonObjectByProtocol;
}

AcInject(_singletonObjectByName, AcName(@"Test Singleton"))
AcInject(_singletonObjectByClass, AcClass(SingletonObject))
AcInject(_singletonObjectByProtocol, AcProtocol(InjectableProtocol))

-(void) setUp {
    [super setUp];
    STStartLogging(@"is [InjectionTests]");
    STStartScope([self class]);
    [self setupRealContext];
    [self addClassesToContext:@[[self class],[SingletonObject class]]];
    AcInjectDependencies(self);
}

-(void) testInjectByName {
    XCTAssertNotNil(_singletonObjectByName);
    XCTAssertTrue([_singletonObjectByName isKindOfClass:[SingletonObject class]]);
}

-(void) testInjectByClass {
    XCTAssertNotNil(_singletonObjectByClass);
    XCTAssertTrue([_singletonObjectByClass isKindOfClass:[SingletonObject class]]);
}

-(void) testInjectByProtocol {
    XCTAssertNotNil(_singletonObjectByProtocol);
    XCTAssertTrue([_singletonObjectByProtocol isKindOfClass:[SingletonObject class]]);
}

@end
