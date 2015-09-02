//
//  ALCClassTests.m
//  Alchemic
//
//  Created by Derek Clarkson on 24/07/2015.
//  Copyright © 2015 Derek Clarkson. All rights reserved.
//

@import XCTest;
#import "ALCClass.h"
#import "ALCTestCase.h"
#import "ALCClassBuilder.h"

@interface ALCClassTests : ALCTestCase

@end

@implementation ALCClassTests

-(void) testFactoryMethod {
	ALCClass *alcClass = [ALCClass withClass:[NSString class]];
	XCTAssertEqual([NSString class], alcClass.aClass);
	XCTAssertEqual([NSString class], alcClass.cacheId);
}

-(void) testIsEqualToClass {
	ALCClass *alcClass1 = [ALCClass withClass:[NSString class]];
	ALCClass *alcClass2 = [ALCClass withClass:[NSString class]];
	XCTAssertTrue([alcClass1 isEqualToClass:alcClass2]);
}

-(void) testIsNotEqualToClass {
	ALCClass *alcClass1 = [ALCClass withClass:[NSString class]];
	ALCClass *alcClass2 = [ALCClass withClass:[NSNumber class]];
	XCTAssertFalse([alcClass1 isEqualToClass:alcClass2]);
}

-(void) testHashMatches {
	ALCClass *alcClass1 = [ALCClass withClass:[NSString class]];
	ALCClass *alcClass2 = [ALCClass withClass:[NSString class]];
	XCTAssertEqual(alcClass1.hash, alcClass2.hash);
}

-(void) testNotHashMatches {
	ALCClass *alcClass1 = [ALCClass withClass:[NSString class]];
	ALCClass *alcClass2 = [ALCClass withClass:[NSNumber class]];
	XCTAssertNotEqual(alcClass1.hash, alcClass2.hash);
}

-(void) testMatchesBuilder {
	ALCClass *alcClass = [ALCClass withClass:[NSString class]];
	id<ALCBuilder> builder = [self simpleBuilderForClass:[NSString class]];
	XCTAssertTrue([alcClass matches:builder]);
}

-(void) testNotMatchesBuilder {
	ALCClass *alcClass = [ALCClass withClass:[NSString class]];
    id<ALCBuilder> builder = [self simpleBuilderForClass:[NSNumber class]];
	XCTAssertFalse([alcClass matches:builder]);
}

-(void) testDescription {
	ALCClass *alcClass = [ALCClass withClass:[NSString class]];
	XCTAssertEqualObjects(@"[NSString]", [alcClass description]);
}

@end
