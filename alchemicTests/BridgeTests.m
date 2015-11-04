//
//  BridgeTests.m
//  alchemic
//
//  Created by Derek Clarkson on 4/11/2015.
//  Copyright © 2015 Derek Clarkson. All rights reserved.
//

#import <XCTest/XCTest.h>
#import <Alchemic/Alchemic.h>
#import <OCMock/OCMock.h>
#import <StoryTeller/StoryTeller.h>

#import "ALCTestCase.h"

@interface BridgeTests : ALCTestCase

@end

@implementation BridgeTests

-(void) testLoadsSwiftObject {

    STStartLogging(@"LogAll");
    STStartLogging(@"is [Alchemic_tests.SwiftObject]");

   	[self setupRealContext];
    [self startContextWithClasses:@[[SwiftObject class]]];

    id obj = AcGet(NSObject, AcClass(SwiftObject));
    XCTAssertNotNil(obj);

    obj = AcGet(NSObject, AcName(@"abc"));
    XCTAssertNotNil(obj);
}

-(void) testModelScannerProcessesSwiftClass {

    [self setupMockContext];

    id mockBuilder = OCMClassMock([ALCBuilder class]);
    OCMExpect([self.mockContext registerBuilderForClass:[SwiftObject class]]).andReturn(mockBuilder);
    OCMExpect([self.mockContext registerClassBuilder:mockBuilder withProperties:[OCMArg isKindOfClass:[NSArray class]]]);
    OCMExpect([self.mockContext classBuilderDidFinishRegistering:mockBuilder]);

    ALCRuntimeScanner *scanner = [ALCRuntimeScanner modelScanner];
    scanner.processor((id)self.mockContext, [NSMutableSet set], [SwiftObject class]);

    OCMVerifyAll(self.mockContext);
}

@end
