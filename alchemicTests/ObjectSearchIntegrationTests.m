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

@protocol OSable <NSObject>
@end

@interface OSObject : NSObject<OSable>
@end

@implementation OSObject
AcRegister(AcWithName(@"abc"))
@end

@interface ObjectSearchIntegrationTests : ALCTestCase
@end

@implementation ObjectSearchIntegrationTests {
	id _objByClass;
	id _objByProtocol;
	id _objByName;
	id _objByEverthing;
}

AcInject(_objByClass, AcClass(OSObject))
AcInject(_objByProtocol, AcProtocol(OSable))
AcInject(_objByName, AcName(@"abc"))
AcInject(_objByEverthing, AcClass(OSObject), AcProtocol(OSable))

-(void) setUp {
    STStartLogging(@"LogAll");
	[self setupRealContext];
	[self startContextWithClasses:@[[OSObject class], [ObjectSearchIntegrationTests class]]];
	AcInjectDependencies(self);
}

-(void) testIntegrationFindingByClass {
	XCTAssertNotNil(_objByClass);
}

-(void) testIntegrationFindingByProtocol {
	XCTAssertNotNil(_objByProtocol);
}

-(void) testIntegrationFindingByName {
	XCTAssertNotNil(_objByName);
}

-(void) testIntegrationFindingByEverything {
	XCTAssertNotNil(_objByEverthing);
}

-(void) testIntegrationCheckSameObjectInAllInjections {
	XCTAssertEqualObjects(_objByClass, _objByProtocol);
	XCTAssertEqualObjects(_objByClass, _objByName);
	XCTAssertEqualObjects(_objByClass, _objByEverthing);
}

@end
