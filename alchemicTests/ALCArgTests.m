//
//  ALCArgTests.m
//  Alchemic
//
//  Created by Derek Clarkson on 23/07/2015.
//  Copyright © 2015 Derek Clarkson. All rights reserved.
//

@import XCTest;
#import "ALCArg.h"
#import "ALCConstantValue.h"
#import "ALCValueSource.h"
#import "ALCConstantValueSource.h"
#import "ALCValueSource.h"
#import <Alchemic/Alchemic.h>

@interface ALCArgTests : XCTestCase

@end

@implementation ALCArgTests

-(void) testWithClass {
	ALCArg *arg = [[ALCArg alloc] initWithType:[NSString class]];
    [arg addMacro:AcValue(@"abc")];
	XCTAssertEqual([NSString class], arg.valueSource.valueClass);
}

-(void) testArgWithTypeMacros {
	ALCArg *arg = [ALCArg argWithType:[NSString class] macros:[ALCConstantValue constantValue:@5], nil];
	XCTAssertEqual([NSString class], arg.valueSource.valueClass);
	ALCConstantValueSource *valueSource = [arg valueSource];
	XCTAssertEqualObjects(@5, [valueSource.values anyObject]);
}

@end
