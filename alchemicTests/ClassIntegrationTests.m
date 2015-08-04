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

@interface CISimpleObject : NSObject<AlchemicAware>
@property (nonatomic, assign, readonly) BOOL injected;
@end

@implementation CISimpleObject
AcRegister()
-(void)didInjectDependencies {
	_injected = YES;
}
@end

@interface ClassIntegrationTests : ALCTestCase
@property (nonatomic, strong) CISimpleObject *simpleObject;
@end

@implementation ClassIntegrationTests

AcInject(simpleObject)

-(void) testCreatingASingleton {
	[self setupRealContext];
	//STStartLogging(ALCHEMIC_LOG);
	STStartLogging(@"[ClassIntegrationTests]");
	[self addClassesToContext:@[[CISimpleObject class], [ClassIntegrationTests class]]];
	AcInjectDependencies(self);
	XCTAssertNotNil(self.simpleObject);
	XCTAssertTrue(self.simpleObject.injected);
}

@end
