//
//  ALCClassBuilderTypeTests.m
//  alchemic
//
//  Created by Derek Clarkson on 8/09/2015.
//  Copyright © 2015 Derek Clarkson. All rights reserved.
//

@import XCTest;
@import ObjectiveC;
#import "ALCClassBuilderType.h"
#import "ALCBuilder.h"
#import <OCMock/OCMock.h>
#import "SimpleObject.h"
#import "ALCMacroProcessor.h"
#import "ALCValueSourceFactory.h"
#import "ALCValueSource.h"

@interface ALCClassBuilderTypeTests : XCTestCase

@end

@implementation ALCClassBuilderTypeTests {
    ALCClassBuilderType *_builderType;
}

-(void)setUp {
    _builderType = [[ALCClassBuilderType alloc] initWithType:[SimpleObject class]];
}

-(void) testBuilderName {
    XCTAssertEqualObjects(@"SimpleObject", _builderType.defaultName);
}

-(void) testMacroProcessorFlags {
    XCTAssertEqual(ALCAllowedMacrosFactory
                   + ALCAllowedMacrosName
                   + ALCAllowedMacrosPrimary
                   + ALCAllowedMacrosExternal,
                   _builderType.macroProcessorFlags);
}

-(void) testInvokeWithArgsThrows {
    XCTAssertThrowsSpecificNamed([_builderType invokeWithArgs:@[]], NSException, @"AlchemicUnexpectedInvokation");
}

-(void) testAttibuteText {
    XCTAssertEqualObjects(@", class builder", _builderType.attributeText);
}

@end
