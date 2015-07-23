//
//  ALCNameTests.m
//  Alchemic
//
//  Created by Derek Clarkson on 24/07/2015.
//  Copyright © 2015 Derek Clarkson. All rights reserved.
//

@import XCTest;
#import "ALCName.h"
#import "ALCClassBuilder.h"

@interface ALCNameTests : XCTestCase

@end

@implementation ALCNameTests

-(void) testFactoryMethod {
	ALCName *alcName = [ALCName withName:@"abc"];
	XCTAssertEqual(@"abc", alcName.aName);
	XCTAssertEqual(@"abc", alcName.cacheId);
}

-(void) testIsEqualToName {
	ALCName *alcName1 = [ALCName withName:@"abc"];
	ALCName *alcName2 = [ALCName withName:@"abc"];
	XCTAssertTrue([alcName1 isEqualToName:alcName2]);
}

-(void) testIsNotEqualToName {
	ALCName *alcName1 = [ALCName withName:@"abc"];
	ALCName *alcName2 = [ALCName withName:@"def"];
	XCTAssertFalse([alcName1 isEqualToName:alcName2]);
}

-(void) testHashMatches {
	ALCName *alcName1 = [ALCName withName:@"abc"];
	ALCName *alcName2 = [ALCName withName:@"abc"];
	XCTAssertEqual(alcName1.hash, alcName2.hash);
}

-(void) testNotHashMatches {
	ALCName *alcName1 = [ALCName withName:@"abc"];
	ALCName *alcName2 = [ALCName withName:@"def"];
	XCTAssertNotEqual(alcName1.hash, alcName2.hash);
}

-(void) testMatchesBuilder {
	ALCName *alcName = [ALCName withName:@"abc"];
	ALCClassBuilder *builder = [[ALCClassBuilder alloc] initWithValueClass:[NSString class]];
	builder.name = @"abc";
	XCTAssertTrue([alcName matches:builder]);
}

-(void) testNotMatchesBuilder {
	ALCName *alcName = [ALCName withName:@"abc"];
	ALCClassBuilder *builder = [[ALCClassBuilder alloc] initWithValueClass:[NSNumber class]];
	builder.name = @"def";
	XCTAssertFalse([alcName matches:builder]);
}

-(void) testDescription {
	ALCName *alcName = [ALCName withName:@"abc"];
	XCTAssertEqualObjects(@"With 'abc'", [alcName description]);
}

@end
