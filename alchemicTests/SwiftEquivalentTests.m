//
//  SwiftEquivalentTests.m
//  Alchemic
//
//  Created by Derek Clarkson on 8/8/16.
//  Copyright © 2016 Derek Clarkson. All rights reserved.
//

@import XCTest;
@import Alchemic;
#import "Singleton.h"
#import "Template.h"
#import "Reference.h"

@interface SwiftEquivalentTests : XCTestCase

@end

// These tests match the Swift integration tests so we can debug here.

@implementation SwiftEquivalentTests {
    Singleton *singleton;
    Template *templateInstance1;
    Template *templateInstance2;
    Reference *nillableReference;
}

AcInject(singleton);
AcInject(templateInstance1);
AcInject(templateInstance2);
AcInject(nillableReference, AcTransient)


-(void) setUp {
    XCTestExpectation *started = [self expectationWithDescription:@"When Alchemic started"];
    [[Alchemic mainContext] executeBlockWhenStarted:^{
        [started fulfill];
    }];
    [self waitForExpectationsWithTimeout: 0.5 handler: nil];
    AcSet(self);
}

-(void) testSingleton {
    XCTAssertNotNil(singleton);
}

-(void) testTemplates {
    XCTAssertNotNil(templateInstance1);
    XCTAssertNotNil(templateInstance2);
    XCTAssertNotEqual(templateInstance1, templateInstance2);
}

-(void) testReference {
    XCTAssertNil(nillableReference);
    Reference *newReference = [[Reference alloc] init];
    AcSet(newReference);
    XCTAssertEqual(newReference, nillableReference);
}

@end
