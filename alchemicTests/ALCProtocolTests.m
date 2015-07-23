//
//  ALCClassTests.m
//  Alchemic
//
//  Created by Derek Clarkson on 24/07/2015.
//  Copyright © 2015 Derek Clarkson. All rights reserved.
//

@import XCTest;
#import "ALCProtocol.h"
#import "ALCClassBuilder.h"

@interface ALCProtocolTests : XCTestCase

@end

@implementation ALCProtocolTests

-(void) testFactoryMethod {
	ALCProtocol *alcProtocol = [ALCProtocol withProtocol:@protocol(NSCopying)];
	XCTAssertEqual(@protocol(NSCopying), alcProtocol.aProtocol);
	XCTAssertEqual(@protocol(NSCopying), alcProtocol.cacheId);
}

-(void) testIsEqualToClass {
	ALCProtocol *alcProtocol1 = [ALCProtocol withProtocol:@protocol(NSCopying)];
	ALCProtocol *alcProtocol2 = [ALCProtocol withProtocol:@protocol(NSCopying)];
	XCTAssertTrue([alcProtocol1 isEqualToProtocol:alcProtocol2]);
}

-(void) testIsNotEqualToClass {
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
	ALCClassBuilder *builder = [[ALCClassBuilder alloc] initWithValueClass:[NSString class]];
	XCTAssertTrue([alcProtocol matches:builder]);
}

-(void) testNotMatchesBuilder {
	ALCProtocol *alcProtocol = [ALCProtocol withProtocol:@protocol(ALCBuilder)];
	ALCClassBuilder *builder = [[ALCClassBuilder alloc] initWithValueClass:[NSNumber class]];
	XCTAssertFalse([alcProtocol matches:builder]);
}

-(void) testDescription {
	ALCProtocol *alcProtocol = [ALCProtocol withProtocol:@protocol(NSCopying)];
	XCTAssertEqualObjects(@"With <NSCopying>", [alcProtocol description]);
}

@end
