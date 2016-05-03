//
//  AlchemicTests.m
//  Alchemic
//
//  Created by Derek Clarkson on 7/04/2016.
//  Copyright © 2016 Derek Clarkson. All rights reserved.
//

#import <XCTest/XCTest.h>

#import <Alchemic/Alchemic.h>

#import "SingletonA.h"
#import "SingletonB.h"
#import "SingletonC.h"
#import "FactoryA.h"
#import "NonManagedObject.h"

@interface AlchemicTests : XCTestCase

@end

@implementation AlchemicTests

-(void) testStartUp {

    SingletonA *a = AcGet(SingletonA);
    XCTAssertNotNil(a);

    SingletonB *b = AcGet(SingletonB);
    XCTAssertNotNil(b);

    XCTAssertEqual(a.singletonB, b);
    XCTAssertEqual(b.singletonA, a);
}

-(void) testSingletonViaName {
    SingletonA *a = AcGet(SingletonA, AcName(@"SingletonAName"));
    XCTAssertNotNil(a);
}

-(void) testFactoryClass {
    FactoryA *a = AcGet(FactoryA);
    FactoryA *b = AcGet(FactoryA);
    XCTAssertNotEqual(a, b);
}

-(void) testAccessingSimpleFactoryMethod {
    NonManagedObject *nmo = AcGet(NonManagedObject);
    XCTAssertNotNil(nmo);
}

-(void) testAccessingSimpleFactoryMethodViaCustomName {
    NonManagedObject *nmo = AcGet(NonManagedObject, AcWithName(@"NonManagedInstance"));
    XCTAssertNotNil(nmo);
}

-(void) testSingletonCreatedUsingInitializer {
    SingletonC *c = AcGet(SingletonC);
    XCTAssertNotNil(c);
    XCTAssertEqual(5, c.aInt);
    XCTAssertNotNil(c.singletonB);
}

@end
