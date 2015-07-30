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

@implementation MSParentClass {
	int count;
}

AcMethod(NSString, createAString, AcWithName(@"abc"))
-(NSString *) createAString {
	STLog(self, @"----> Creating a object with count %i", count);
	return [NSString stringWithFormat:@"hello world %i", count++];
}

AcMethod(NSString, createAStringFromAString:, AcArg(NSString, AcName(@"abc")), AcWithName(@"def"))
-(NSString *) createAStringFromAString:(NSString *) aString {
	STLog(self, @"----> Creating a object with text %@", aString);
	return [aString stringByAppendingString:@" again !"];
}

@end

@interface MethodSingletonIntegrationTests : ALCTestCase
@end

@implementation MethodSingletonIntegrationTests {
	NSString *_aString1;
	NSString *_aString2;
	NSString *_aString3;
}

AcInject(_aString1, AcName(@"abc"))
AcInject(_aString2, AcName(@"abc"))
AcInject(_aString3, AcName(@"def"))

-(void) testCreatingASingleton {
	[self setupRealContext];
	STStartLogging(ALCHEMIC_LOG);
	STStartLogging(@"[MSParentClass]");
	STStartLogging(@"[MethodSingletonIntegrationTests]");
	[self addClassesToContext:@[[MSParentClass class], [MethodSingletonIntegrationTests class]]];
	AcInjectDependencies(self);
	XCTAssertEqualObjects(@"hello world 0", _aString1);
	XCTAssertEqualObjects(@"hello world 0", _aString2);
}

-(void) testCreatingASingletonWithAnArg {
	[self setupRealContext];
	STStartLogging(@"[MethodSingletonIntegrationTests]");
	[self addClassesToContext:@[[MSParentClass class], [MethodSingletonIntegrationTests class]]];
	AcInjectDependencies(self);
	XCTAssertEqualObjects(@"hello world 0 again !", _aString3);
}

@end
