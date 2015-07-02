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

ACInject(ACIntoVariable(_singletonObjectByName), ACWithName(@"Test Singleton"))
ACInject(ACIntoVariable(_singletonObjectByClass), ACWithClass(SingletonObject))
ACInject(ACIntoVariable(_singletonObjectByProtocol), ACWithProtocol(InjectableProtocol))

-(void) setUp {
    STStartLogging(@"[ALCClassBuilder]");
    STStartLogging(@"[SingletonObject]");
    STStartLogging(@"<ALCBuilder>.valueType.typeClass == [SingletonObject]");
    ACInjectDependencies(self);
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
