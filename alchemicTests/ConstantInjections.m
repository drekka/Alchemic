//
//  SingletonTests.m
//  Alchemic
//
//  Created by Derek Clarkson on 5/02/2016.
//  Copyright © 2016 Derek Clarkson. All rights reserved.
//

@import XCTest;
@import UIKit;

#import <StoryTeller/StoryTeller.h>
#import <Alchemic/Alchemic.h>

//#import "ALCClassObjectFactory.h"
//#import "ALCContextImpl.h"

#import "TopThing.h"

@interface ConstantInjections : XCTestCase
@end

@implementation ConstantInjections {
    id<ALCContext> _context;
    ALCClassObjectFactory *_topThingFactory;
}

-(void)setUp {
    STStartLogging(@"[Alchemic]");
    STStartLogging(@"<ALCContext>");
    STStartLogging(@"is [TopThing]");
    _context = [[ALCContextImpl alloc] init];
    _topThingFactory = [_context registerObjectFactoryForClass:[TopThing class]];
}

-(void) testConstantBool {
    TopThing *topThing = [self setUpTestForProperty:@"aBool" constant:AcBool(5)];
    XCTAssertTrue(topThing.aBool);
}

-(void) testConstantInt {
    TopThing *topThing = [self setUpTestForProperty:@"aInt" constant:AcInt(5)];
    XCTAssertEqual(5, topThing.aInt);
}

-(void) testConstantLong {
    TopThing *topThing = [self setUpTestForProperty:@"aLong" constant:AcLong(5)];
    XCTAssertEqual(5, topThing.aLong);
}

-(void) testConstantFloat {
    TopThing *topThing = [self setUpTestForProperty:@"aFloat" constant:AcFloat(5)];
    XCTAssertEqual(5, topThing.aFloat);
}

-(void) testConstantDouble {
    TopThing *topThing = [self setUpTestForProperty:@"aDouble" constant:AcDouble(5)];
    XCTAssertEqual(5, topThing.aDouble);
}

-(void) testConstantCGFloat {
    TopThing *topThing = [self setUpTestForProperty:@"aCGFloat" constant:AcCGFloat(5)];
    XCTAssertEqual(5, topThing.aCGFloat);
}

-(void) testConstantCGSize {
    TopThing *topThing = [self setUpTestForProperty:@"aCGSize" constant:AcCGSize(CGSizeMake(5, 10))];
    XCTAssertTrue(CGSizeEqualToSize(CGSizeMake(5, 10), topThing.aCGSize));
}

-(void) testConstantCGRect {
    TopThing *topThing = [self setUpTestForProperty:@"aCGRect" constant:AcCGRect(CGRectMake(5, 10, 15, 20))];
    XCTAssertTrue(CGRectEqualToRect(CGRectMake(5, 10, 15, 20), topThing.aCGRect));
}

-(void) testConstantString {
    TopThing *topThing = [self setUpTestForProperty:@"aString" constant:AcString(@"hello")];
    XCTAssertEqualObjects(@"hello", topThing.aString);
}

-(id) setUpTestForProperty:(NSString *) property
                  constant:(id<ALCInjection>) constant {
    [_context objectFactory:_topThingFactory registerVariableInjection:property, constant, nil];
    [_context start];
    TopThing *topThing = _topThingFactory.instantiation.object;
    return topThing;
}

@end
