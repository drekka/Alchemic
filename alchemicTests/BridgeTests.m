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

#import "ALCRuntimeScanner.h"

#import "AlchemicSwift_Tests-Swift.h"
#import "ALCTestCase.h"

@interface BridgeTests : ALCTestCase
@end

@implementation BridgeTests

-(void) testLoadsSwiftNSObject {

    STStartLogging(@"LogAll");
    STStartLogging(@"is [Alchemic_tests.SwiftNSObject]");

   	[self setupRealContext];
    [self startContextWithClasses:@[[SwiftNSObject class]]];

    id obj = AcGet(NSObject, AcClass(SwiftNSObject));
    XCTAssertNotNil(obj);

    obj = AcGet(NSObject, AcName(@"abc"));
    XCTAssertNotNil(obj);
}

-(void) testModelScannerProcessesSwiftNSObjectClass {

    [self setupMockContext];

    id mockBuilder = OCMClassMock([ALCBuilder class]);
    OCMExpect([self.mockContext registerBuilderForClass:[SwiftNSObject class]]).andReturn(mockBuilder);
    OCMExpect([self.mockContext registerClassBuilder:mockBuilder withProperties:[OCMArg isKindOfClass:[NSArray class]]]);
    OCMExpect([self.mockContext classBuilderDidFinishRegistering:mockBuilder]);

    ALCRuntimeScanner *scanner = [ALCRuntimeScanner modelScanner];
    scanner.processor((id)self.mockContext, [NSMutableSet set], [SwiftNSObject class]);

    OCMVerifyAll(self.mockContext);
}

@end
