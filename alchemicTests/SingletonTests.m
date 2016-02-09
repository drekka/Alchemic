//
//  SingletonTests.m
//  Alchemic
//
//  Created by Derek Clarkson on 5/02/2016.
//  Copyright © 2016 Derek Clarkson. All rights reserved.
//

@import XCTest;

#import <Alchemic/Alchemic.h>

@interface Singleton : NSObject
@end

@implementation Singleton
@end

@interface SingletonTests : XCTestCase
@end

@implementation SingletonTests

-(void) testInstantiation {

    id<ALCContext> context = [[ALCContextImpl alloc] init];
    id<ALCObjectFactory> valueFactory = [context registerClass:[Singleton class]];
    [context start];

    XCTAssertTrue(valueFactory.resolved);

    id value = valueFactory.object;
    XCTAssertTrue([value isKindOfClass:[Singleton class]]);
}

@end
