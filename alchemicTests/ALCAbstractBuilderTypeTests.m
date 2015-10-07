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

@implementation ALCAbstractBuilderTypeTests {
    ALCAbstractBuilderType *_builderType;
    id _mockMacroProcessor;
}

-(void)setUp {
    _builderType = [[ALCAbstractBuilderType alloc] init];
    _mockMacroProcessor = OCMClassMock([ALCMacroProcessor class]);
}

-(void) testConfigureThrowsIfNoBuilderSet {
    XCTAssertThrowsSpecificNamed([_builderType configureWithMacroProcessor:_mockMacroProcessor], NSException, @"AlchemicBuilderNotSet");
}

@end
