//
//  FactoryObjectTests.m
//  alchemic
//
//  Created by Derek Clarkson on 17/06/2015.
//  Copyright © 2015 Derek Clarkson. All rights reserved.
//

#import "FactoryObject.h"
#import "ALCTestCase.h"
#import <Alchemic/Alchemic.h>


@interface FactoryObjectTests : ALCTestCase
@end

@implementation FactoryObjectTests {
    FactoryObject *_of1;
    FactoryObject *_of2;
}

ACInject(ACIntoVariable(_of1))
ACInject(ACIntoVariable(_of2), ACWithClass(FactoryObject))

-(void) testFactory {
    XCTAssertNotNil(_of1);
    XCTAssertNotNil(_of2);
    XCTAssertEqual(_of1, _of2);
}

@end
