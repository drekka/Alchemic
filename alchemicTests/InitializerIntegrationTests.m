//
//  InitializerIntegrationTests.m
//  Alchemic
//
//  Created by Derek Clarkson on 31/07/2015.
//  Copyright © 2015 Derek Clarkson. All rights reserved.
//

#import "ALCTestCase.h"
#import <Alchemic/Alchemic.h>
#import <StoryTeller/StoryTeller.h>

@interface ITSimpleObject1 : NSObject
@property (nonatomic, strong) NSString *prop;
@end

@implementation ITSimpleObject1

AcInitializer(initWithNoArgs)
-(instancetype) initWithNoArgs {
	self = [super init];
	if (self) {
		self.prop = @"abc";
	}
	return self;
}

@end

@interface ITSimpleObject2 : NSObject
@property (nonatomic, strong) NSString *prop;
@property (nonatomic, strong, readonly) ITSimpleObject1 *so1;
@end

@implementation ITSimpleObject2

AcInitializer(initWithSimpleObject1:, AcArg(ITSimpleObject1, AcClass(ITSimpleObject1)))
-(instancetype) initWithSimpleObject1:(ITSimpleObject1 *) so1 {
	self = [super init];
	if (self) {
		_so1 = so1;
		self.prop = @"def";
	}
	return self;
}

@end

#pragma mark - Tests

@interface InitializerIntegrationTests : ALCTestCase
@end

@implementation InitializerIntegrationTests {
	ITSimpleObject1 *_so1;
	ITSimpleObject2 *_so2;
}

AcInject(_so1)
AcInject(_so2)

-(void) testIntegrationNoArgInit {
	STStartLogging(ALCHEMIC_LOG);
	[self setupRealContext];
	[self startContextWithClasses:@[[ITSimpleObject1 class], [ITSimpleObject2 class], [InitializerIntegrationTests class]]];
	AcInjectDependencies(self);
	XCTAssertNotNil(_so1);
	XCTAssertEqualObjects(@"abc", _so1.prop);
}

-(void) testIntegrationSingleArgInit {
	[self setupRealContext];
	[self startContextWithClasses:@[[ITSimpleObject1 class], [ITSimpleObject2 class], [InitializerIntegrationTests class]]];
	AcInjectDependencies(self);
	XCTAssertNotNil(_so2);
	XCTAssertEqualObjects(@"def", _so2.prop);
	XCTAssertEqualObjects(@"abc", _so2.so1.prop);
}


@end
