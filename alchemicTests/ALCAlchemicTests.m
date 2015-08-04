//
//  ALCAlchemicTests.m
//  Alchemic
//
//  Created by Derek Clarkson on 4/08/2015.
//  Copyright © 2015 Derek Clarkson. All rights reserved.
//

@import XCTest;
@import ObjectiveC;
#import "ALCAlchemic.h"
#import <OCMock/OCMock.h>
#import "ALCcontext.h"


@interface ALCAlchemicTests : XCTestCase

@end

@implementation ALCAlchemicTests

-(void) testStartMainContext {
	@try {
		((void (*)(id, SEL))objc_msgSend)([ALCAlchemic class], @selector(start));
	}
	@catch(NSException *e) {
		// We don't care.
	}
	XCTAssertNotNil([ALCAlchemic mainContext]);
}

@end
