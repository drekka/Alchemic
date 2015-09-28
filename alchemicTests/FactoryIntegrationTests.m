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

@interface CISimpleFactory : NSObject
@end

@implementation CISimpleFactory
AcRegister(AcFactory)
@end

@interface FactoryIntegrationTests : ALCTestCase
@end

@implementation FactoryIntegrationTests {
	CISimpleFactory *_simpleFactory1;
	CISimpleFactory *_simpleFactory2;
}

AcInject(_simpleFactory1)
AcInject(_simpleFactory2)

-(void) testCreatingASFactory {
	[self setupRealContext];
	STStartLogging(@"[FactoryIntegrationTests]");
	[self startContextWithClasses:@[[CISimpleFactory class], [FactoryIntegrationTests class]]];
	AcInjectDependencies(self);
	XCTAssertNotNil(_simpleFactory1);
	XCTAssertNotNil(_simpleFactory2);
	XCTAssertNotEqual(_simpleFactory1, _simpleFactory2);
}

@end
