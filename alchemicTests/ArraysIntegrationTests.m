//
//  ArraysIntegrationTests.m
//  Alchemic
//
//  Created by Derek Clarkson on 31/07/2015.
//  Copyright © 2015 Derek Clarkson. All rights reserved.
//

#import "ALCTestCase.h"
#import <StoryTeller/StoryTeller.h>

@interface ArraysIntegrationTests : ALCTestCase

@end

@implementation ArraysIntegrationTests {
	NSArray *_dateFormatters;
	NSDateFormatter *_df1;
	NSDateFormatter *_df2;
}

AcInject(_dateFormatters, AcClass(NSDateFormatter))
AcInject(_df1, AcName(@"df1"))
AcInject(_df2, AcName(@"df2"))

-(void) testNoArgInit {
	STStartLogging(ALCHEMIC_LOG);
	[self setupRealContext];
	[self addClassesToContext:@[[ArraysIntegrationTests class]]];
	AcInjectDependencies(self);
	XCTAssertNotNil(_dateFormatters);
	XCTAssertNotNil(_df1);
	XCTAssertNotNil(_df2);
	XCTAssertNotEqual(_df1, _df2);
	XCTAssertTrue([_dateFormatters containsObject:_df1]);
	XCTAssertTrue([_dateFormatters containsObject:_df2]);
}


#pragma mark - Factories

AcMethod(NSDateFormatter, dateFormatter, AcWithName(@"df1"))
AcMethod(NSDateFormatter, dateFormatter, AcWithName(@"df2"))
-(NSDateFormatter *) dateFormatter {
	return [[NSDateFormatter alloc] init];
}



@end
