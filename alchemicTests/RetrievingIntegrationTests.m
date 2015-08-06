//
//  RetrievingIntegrationTests.m
//  Alchemic
//
//  Created by Derek Clarkson on 6/08/2015.
//  Copyright © 2015 Derek Clarkson. All rights reserved.
//

#import "ALCTestCase.h"

@protocol REProtocol <NSObject>
@end

@interface REObject : NSObject<REProtocol>
@end

@implementation REObject
AcRegister(AcWithName(@"abc"))
@end

@interface RetrievingIntegrationTests : ALCTestCase
@end

@implementation RetrievingIntegrationTests

-(void) setUp {
	[super setUp];
	[self setupRealContext];
	[self addClassesToContext:@[[REObject class]]];
}

-(void) testGet {
	[self checkIsREObject:AcGet(REObject)];
}

-(void) testGetbyClass {
	[self checkIsREObject:AcGet(REObject, AcClass(REObject))];
}

-(void) testGetbyProtocol {
	[self checkIsREObject:AcGet(REObject, AcProtocol(REProtocol))];
}

-(void) testGetbyName {
	[self checkIsREObject:AcGet(REObject, AcName(@"abc"))];
}

-(void) testGetbyEverything {
	[self checkIsREObject:AcGet(REObject, AcClass(REObject), AcProtocol(REProtocol), AcName(@"abc"))];
}

-(void) testGetThrowsWhenFactory {
	XCTAssertThrowsSpecificNamed((AcGet(REObject, AcIsFactory)), NSException, @"AlchemicUnexpectedMacro");
}

#pragma mark - Internal

-(void) checkIsREObject:(id) value {
	XCTAssertNotNil(value);
	XCTAssertTrue([value isKindOfClass:[REObject class]]);
}

@end
