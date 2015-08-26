//
//  ALCClassInstantiatorTests.m
//  alchemic
//
//  Created by Derek Clarkson on 25/08/2015.
//  Copyright © 2015 Derek Clarkson. All rights reserved.
//

@import XCTest;
#import "ALCClassInstantiator.h"
#import "SimpleObject.h"

@interface ALCClassInstantiatorTests : XCTestCase
@end

@implementation ALCClassInstantiatorTests

-(void) testBuilderName {
    ALCClassInstantiator *instantiator = [[ALCClassInstantiator alloc] initWithObjectType:[NSString class]];
    XCTAssertEqualObjects(@"NSString", instantiator.builderName);
}

-(void) testCreatingAnObject {
    ALCClassInstantiator *instantiator = [[ALCClassInstantiator alloc] initWithObjectType:[SimpleObject class]];
    SimpleObject *so = [instantiator instantiateWithArguments:@[]];
    XCTAssertNotNil(so);
}

@end
