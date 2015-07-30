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
AcInject(_objByEverthing, AcName(@"abc"), AcClass(OSObject), AcProtocol(OSable))

-(void) setUp {
	[self setupRealContext];
	[self addClassesToContext:@[[OSObject class], [ObjectSearchIntegrationTests class]]];
	AcInjectDependencies(self);
}

-(void) testFindingByClass {
	XCTAssertNotNil(_objByClass);
}

-(void) testFindingByProtocol {
	XCTAssertNotNil(_objByProtocol);
}

-(void) testFindingByName {
	XCTAssertNotNil(_objByName);
}

-(void) testFindingByEverything {
	XCTAssertNotNil(_objByEverthing);
}

-(void) testCheckSameObjectInAllInjections {
	XCTAssertEqualObjects(_objByClass, _objByProtocol);
	XCTAssertEqualObjects(_objByClass, _objByName);
	XCTAssertEqualObjects(_objByClass, _objByEverthing);
}

@end
