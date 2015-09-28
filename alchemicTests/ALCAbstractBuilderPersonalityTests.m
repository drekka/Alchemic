//
//  ALCAbstractPersonalityTests.m
//  alchemic
//
//  Created by Derek Clarkson on 5/09/2015.
//  Copyright © 2015 Derek Clarkson. All rights reserved.
//

@import XCTest;
#import "ALCAbstractBuilderPersonality.h"
#import <OCMock/OCMock.h>
#import "ALCMacroProcessor.h"

@interface ALCAbstractBuilderPersonalityTests : XCTestCase

@end

@implementation ALCAbstractBuilderPersonalityTests

-(void) testConfigureThrowsIfNoBuilderSet {
    ALCAbstractBuilderPersonality *personality = [[ALCAbstractBuilderPersonality alloc] init];
    id mockMacroProcessor = OCMClassMock([ALCMacroProcessor class]);
    XCTAssertThrowsSpecificNamed([personality configureWithMacroProcessor:mockMacroProcessor], NSException, @"AlchemicBuilderNotSet");
}

@end
