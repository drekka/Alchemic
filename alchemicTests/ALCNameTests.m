//
//  ALCNameTests.m
//  Alchemic
//
//  Created by Derek Clarkson on 24/07/2015.
//  Copyright © 2015 Derek Clarkson. All rights reserved.
//

@import XCTest;
#import "ALCName.h"
#import "ALCTestCase.h"
#import "ALCBuilder.h"
#import "ALCMacroProcessor.h"
#import <Alchemic/Alchemic.h>

@interface ALCNameTests : ALCTestCase

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
	id<ALCBuilder> builder = [self simpleBuilderForClass:[NSString class]];
    [builder.macroProcessor addMacro:AcWithName(@"abc")];
    [builder configure];
	XCTAssertTrue([alcName matches:builder]);
}

-(void) testNotMatchesBuilder {
	ALCName *alcName = [ALCName withName:@"abc"];
    id<ALCBuilder> builder = [self simpleBuilderForClass:[NSNumber class]];
    [builder.macroProcessor addMacro:AcWithName(@"def")];
    [builder configure];
	XCTAssertFalse([alcName matches:builder]);
}

-(void) testDescription {
	ALCName *alcName = [ALCName withName:@"abc"];
	XCTAssertEqualObjects(@"'abc'", [alcName description]);
}

@end
