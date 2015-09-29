//
//  RetrievingIntegrationTests.m
//  Alchemic
//
//  Created by Derek Clarkson on 6/08/2015.
//  Copyright © 2015 Derek Clarkson. All rights reserved.
//

#import "ALCTestCase.h"
#import <Alchemic/Alchemic.h>

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
	[self setupRealContext];
	[self startContextWithClasses:@[[REObject class]]];
}

-(void) testIntegrationGet {
	[self checkIsREObject:AcGet(REObject)];
}

-(void) testIntegrationGetbyClass {
	[self checkIsREObject:AcGet(REObject, AcClass(REObject))];
}

-(void) testIntegrationGetbyProtocol {
	[self checkIsREObject:AcGet(REObject, AcProtocol(REProtocol))];
}

-(void) testIntegrationGetbyName {
	[self checkIsREObject:AcGet(REObject, AcName(@"abc"))];
}

-(void) testIntegrationGetbyEverything {
	[self checkIsREObject:AcGet(REObject, AcClass(REObject), AcProtocol(REProtocol))];
}

-(void) testIntegrationGetThrowsWhenFactory {
	XCTAssertThrowsSpecificNamed((AcGet(REObject, AcFactory)), NSException, @"AlchemicUnexpectedMacro");
}

#pragma mark - Internal

-(void) checkIsREObject:(id) value {
	XCTAssertNotNil(value);
	XCTAssertTrue([value isKindOfClass:[REObject class]]);
}

@end
