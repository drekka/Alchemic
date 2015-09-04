//
//  ALCClassTests.m
//  Alchemic
//
//  Created by Derek Clarkson on 24/07/2015.
//  Copyright © 2015 Derek Clarkson. All rights reserved.
//

@import XCTest;
#import "ALCProtocol.h"
#import "ALCBuilder.h"
#import "ALCTestCase.h"
#import "ALCBuilder.h"

@interface ALCProtocolTests : ALCTestCase

@end

@implementation ALCProtocolTests

-(void) testFactoryMethod {
	ALCProtocol *alcProtocol = [ALCProtocol withProtocol:@protocol(NSCopying)];
	XCTAssertEqual(@protocol(NSCopying), alcProtocol.aProtocol);
	XCTAssertEqual(@protocol(NSCopying), alcProtocol.cacheId);
}

-(void) testIsEqualWhenSameObject {
	ALCProtocol *alcProtocol1 = [ALCProtocol withProtocol:@protocol(NSCopying)];
	XCTAssertTrue([alcProtocol1 isEqual:alcProtocol1]);
}

-(void) testIsEqualWhenSameProtocolObject {
	ALCProtocol *alcProtocol1 = [ALCProtocol withProtocol:@protocol(NSCopying)];
	ALCProtocol *alcProtocol2 = [ALCProtocol withProtocol:@protocol(NSCopying)];
	XCTAssertTrue([alcProtocol1 isEqual:alcProtocol2]);
}

-(void) testIsEqualWhenDifferentProtocolObject {
	ALCProtocol *alcProtocol1 = [ALCProtocol withProtocol:@protocol(NSCopying)];
	ALCProtocol *alcProtocol2 = [ALCProtocol withProtocol:@protocol(NSFastEnumeration)];
	XCTAssertFalse([alcProtocol1 isEqual:alcProtocol2]);
}

-(void) testIsEqualWhenNil {
	ALCProtocol *alcProtocol1 = [ALCProtocol withProtocol:@protocol(NSCopying)];
	XCTAssertFalse([alcProtocol1 isEqual:nil]);
}

-(void) testIsEqualToProtocol {
	ALCProtocol *alcProtocol1 = [ALCProtocol withProtocol:@protocol(NSCopying)];
	ALCProtocol *alcProtocol2 = [ALCProtocol withProtocol:@protocol(NSCopying)];
	XCTAssertTrue([alcProtocol1 isEqualToProtocol:alcProtocol2]);
}

-(void) testIsNotEqualToProtocol {
	ALCProtocol *alcProtocol1 = [ALCProtocol withProtocol:@protocol(NSCopying)];
	ALCProtocol *alcProtocol2 = [ALCProtocol withProtocol:@protocol(ALCBuilder)];
	XCTAssertFalse([alcProtocol1 isEqualToProtocol:alcProtocol2]);
}

-(void) testHashMatches {
	ALCProtocol *alcProtocol1 = [ALCProtocol withProtocol:@protocol(NSCopying)];
	ALCProtocol *alcProtocol2 = [ALCProtocol withProtocol:@protocol(NSCopying)];
	XCTAssertEqual(alcProtocol1.hash, alcProtocol2.hash);
}

-(void) testNotHashMatches {
	ALCProtocol *alcProtocol1 = [ALCProtocol withProtocol:@protocol(NSCopying)];
	ALCProtocol *alcProtocol2 = [ALCProtocol withProtocol:@protocol(ALCBuilder)];
	XCTAssertNotEqual(alcProtocol1.hash, alcProtocol2.hash);
}

-(void) testMatchesBuilder {
	ALCProtocol *alcProtocol = [ALCProtocol withProtocol:@protocol(NSCopying)];
    ALCBuilder *builder = [self simpleBuilderForClass:[NSString class]];
	XCTAssertTrue([alcProtocol matches:builder]);
}

-(void) testNotMatchesBuilder {
	ALCProtocol *alcProtocol = [ALCProtocol withProtocol:@protocol(ALCBuilder)];
    ALCBuilder *builder = [self simpleBuilderForClass:[NSNumber class]];
	XCTAssertFalse([alcProtocol matches:builder]);
}

-(void) testDescription {
	ALCProtocol *alcProtocol = [ALCProtocol withProtocol:@protocol(NSCopying)];
	XCTAssertEqualObjects(@"<NSCopying>", [alcProtocol description]);
}

@end
