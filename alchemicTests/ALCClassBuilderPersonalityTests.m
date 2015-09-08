//
//  ALCClassBuilderPersonalityTests.m
//  alchemic
//
//  Created by Derek Clarkson on 8/09/2015.
//  Copyright © 2015 Derek Clarkson. All rights reserved.
//

@import XCTest;
@import ObjectiveC;
#import "ALCClassBuilderPersonality.h"
#import "ALCBuilder.h"
#import <OCMock/OCMock.h>
#import "SimpleObject.h"
#import "ALCMacroProcessor.h"
#import "ALCValueSourceFactory.h"
#import "ALCValueSource.h"

@interface ALCClassBuilderPersonalityTests : XCTestCase

@end

@implementation ALCClassBuilderPersonalityTests {
    ALCClassBuilderPersonality *_personality;
    id _mockBuilder;
}

-(void)setUp {
    _personality = [[ALCClassBuilderPersonality alloc] init];
    _mockBuilder = OCMClassMock([ALCBuilder class]);
    _personality.builder = _mockBuilder;
}

-(void) testType {
    XCTAssertEqual(ALCBuilderPersonalityTypeClass, _personality.type);
}

-(void) testBuilderName {
    OCMStub([_mockBuilder valueClass]).andReturn([SimpleObject class]);
    XCTAssertEqualObjects(@"SimpleObject", _personality.builderName);
}

-(void) testMacroProcessorFlags {
    XCTAssertEqual(ALCAllowedMacrosFactory
                   + ALCAllowedMacrosName
                   + ALCAllowedMacrosPrimary
                   + ALCAllowedMacrosExternal,
                   _personality.macroProcessorFlags);
}

-(void) testAddVariableInjection {

    id mockValueSourceFactory = OCMClassMock([ALCValueSourceFactory class]);
    id mockValueSource = OCMProtocolMock(@protocol(ALCValueSource));
    OCMStub([mockValueSourceFactory valueSource]).andReturn(mockValueSource);

    Ivar mockBuilderRef = class_getInstanceVariable([self class], "_mockBuilder");

    [_personality addVariableInjection:mockBuilderRef
                    valueSourceFactory:mockValueSourceFactory];

    OCMVerify([(ALCBuilder *)_mockBuilder addDependency:mockValueSource]);
}

-(void) testInvokeWithArgsThrows {
    XCTAssertThrowsSpecificNamed([_personality invokeWithArgs:@[]], NSException, @"AlchemicUnexpectedInvokation");
}

-(void) testAttibuteText {
    XCTAssertEqualObjects(@", class builder", _personality.attributeText);
}

@end
