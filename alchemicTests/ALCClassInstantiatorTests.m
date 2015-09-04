//
//  ALCClassInstantiatorTests.m
//  alchemic
//
//  Created by Derek Clarkson on 25/08/2015.
//  Copyright © 2015 Derek Clarkson. All rights reserved.
//

@import XCTest;
#import "ALCInstantiator.h"
#import "ALCClassInstantiator.h"
#import "SimpleObject.h"
#import "ALCBuilder.h"

@interface ALCClassInstantiatorTests : XCTestCase
@end

@implementation ALCClassInstantiatorTests

-(void) testBuilderName {
    ALCClassInstantiator *instantiator = [[ALCClassInstantiator alloc] initWithClass:[NSString class]];
    XCTAssertEqualObjects(@"NSString", instantiator.builderName);
}

-(void) testCreatingAnObject {
    ALCClassInstantiator *instantiator = [[ALCClassInstantiator alloc] initWithClass:[SimpleObject class]];
    ALCBuilder *builder = [[ALCBuilder alloc] initWithInstantiator:instantiator forClass:[SimpleObject class]];
    SimpleObject *so = [instantiator instantiateWithClassBuilder:builder arguments:@[]];
    XCTAssertNotNil(so);
}

@end
