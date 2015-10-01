//
//  ALCAbstractALCBuilderTypeTests.m
//  alchemic
//
//  Created by Derek Clarkson on 5/09/2015.
//  Copyright © 2015 Derek Clarkson. All rights reserved.
//

@import XCTest;
#import "ALCAbstractBuilderType.h"
#import <OCMock/OCMock.h>
#import "ALCMacroProcessor.h"

@interface ALCAbstractBuilderTypeTests : XCTestCase

@end

@implementation ALCAbstractBuilderTypeTests

-(void) testConfigureThrowsIfNoBuilderSet {
    ALCAbstractBuilderType *builderType = [[ALCAbstractBuilderType alloc] init];
    id mockMacroProcessor = OCMClassMock([ALCMacroProcessor class]);
    XCTAssertThrowsSpecificNamed([builderType configureWithMacroProcessor:mockMacroProcessor], NSException, @"AlchemicBuilderNotSet");
}

@end
