//
//  ClassIntegrationTests.m
//  Alchemic
//
//  Created by Derek Clarkson on 29/07/2015.
//  Copyright © 2015 Derek Clarkson. All rights reserved.
//

#import "ALCTestCase.h"
#import <Alchemic/Alchemic.h>
#import <StoryTeller/StoryTeller.h>

@interface MSParentClass : NSObject
@end

@implementation MSParentClass

AcMethod(NSString, createAString, AcWithName(@"abc"))

-(NSString *) createAString {
	return @"hello world";
}

@end

@interface MethodSingletonIntegrationTests : ALCTestCase
@end

@implementation MethodSingletonIntegrationTests {
	NSString *_aString;
}

AcInject(_aString, AcName(@"abc"))

-(void) testCreatingASingleton {
	[self setupRealContext];
	STStartLogging(@"[MethodSingletonIntegrationTests]");
	[self addClassesToContext:@[[MSParentClass class], [MethodSingletonIntegrationTests class]]];
	AcInjectDependencies(self);
	XCTAssertEqualObjects(@"hello world", _aString);
}

@end
