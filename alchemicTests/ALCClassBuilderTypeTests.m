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
    id _mockBuilder;
}

-(void)setUp {
    _builderType = [[ALCClassBuilderType alloc] init];
    _mockBuilder = OCMClassMock([ALCBuilder class]);
    _builderType.builder = _mockBuilder;
}

-(void) testBuilderName {
    OCMStub([_mockBuilder valueClass]).andReturn([SimpleObject class]);
    XCTAssertEqualObjects(@"SimpleObject", _builderType.builderName);
}

-(void) testMacroProcessorFlags {
    XCTAssertEqual(ALCAllowedMacrosFactory
                   + ALCAllowedMacrosName
                   + ALCAllowedMacrosPrimary
                   + ALCAllowedMacrosExternal,
                   _builderType.macroProcessorFlags);
}

-(void) testAddVariableInjection {

    id mockValueSourceFactory = OCMClassMock([ALCValueSourceFactory class]);
    id mockValueSource = OCMProtocolMock(@protocol(ALCValueSource));
    OCMStub([mockValueSourceFactory valueSource]).andReturn(mockValueSource);

    Ivar mockBuilderRef = class_getInstanceVariable([self class], "_mockBuilder");

    [_builderType addVariableInjection:mockBuilderRef
                    valueSourceFactory:mockValueSourceFactory];

    OCMVerify([(ALCBuilder *)_mockBuilder addDependency:mockValueSource]);
}

-(void) testInvokeWithArgsThrows {
    XCTAssertThrowsSpecificNamed([_builderType invokeWithArgs:@[]], NSException, @"AlchemicUnexpectedInvokation");
}

-(void) testAttibuteText {
    XCTAssertEqualObjects(@", class builder", _builderType.attributeText);
}

@end
