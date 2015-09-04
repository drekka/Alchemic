//
//  ALCPrimaryObjectDependencyPostProcessorTests.m
//  Alchemic
//
//  Created by Derek Clarkson on 29/07/2015.
//  Copyright © 2015 Derek Clarkson. All rights reserved.
//

@import XCTest;
#import "ALCPrimaryObjectDependencyPostProcessor.h"
#import <OCMock/OCMock.h>
#import "ALCbuilder.h"

@interface ALCPrimaryObjectDependencyPostProcessorTests : XCTestCase

@end

@implementation ALCPrimaryObjectDependencyPostProcessorTests

-(void) testReturnsPrimaryObject {

	id mockBuilder1 = OCMProtocolMock(@protocol(ALCBuilder));
	id mockBuilder2 = OCMProtocolMock(@protocol(ALCBuilder));

	OCMStub([mockBuilder1 primary]).andReturn(YES);

	ALCPrimaryObjectDependencyPostProcessor *postProcessor = [[ALCPrimaryObjectDependencyPostProcessor alloc] init];
	NSSet<ALCBuilder> *results = [postProcessor process:[NSSet setWithObjects:mockBuilder1, mockBuilder2, nil]];

	XCTAssertTrue([results containsObject:mockBuilder1]);
	XCTAssertFalse([results containsObject:mockBuilder2]);

}

-(void) testReturnsAllObjectsWhenNoPrimary {

	id mockBuilder1 = OCMProtocolMock(@protocol(ALCBuilder));
	id mockBuilder2 = OCMProtocolMock(@protocol(ALCBuilder));

	ALCPrimaryObjectDependencyPostProcessor *postProcessor = [[ALCPrimaryObjectDependencyPostProcessor alloc] init];
	NSSet<ALCBuilder> *results = [postProcessor process:[NSSet setWithObjects:mockBuilder1, mockBuilder2, nil]];

	XCTAssertTrue([results containsObject:mockBuilder1]);
	XCTAssertTrue([results containsObject:mockBuilder2]);
	
}

@end
