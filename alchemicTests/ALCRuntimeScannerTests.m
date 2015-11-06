//
//  ALCRuntimeScannerTests.m
//  alchemic
//
//  Created by Derek Clarkson on 20/10/2015.
//  Copyright © 2015 Derek Clarkson. All rights reserved.
//

#import "ALCTestCase.h"
@import ObjectiveC;
#import <OCMock/OCMock.h>
#import <Alchemic/Alchemic.h>

#import "ALCRuntimeScanner.h"
#import "ALCContext.h"

#import "Alchemic_tests-Swift.h"

@interface ModelObject : NSObject
@end

@implementation ModelObject
AcRegister()
@end

@interface ALCRuntimeScannerTests : ALCTestCase
@end

@implementation ALCRuntimeScannerTests

-(void) testModelScannerAcceptsAllClasses {
    ALCRuntimeScanner *scanner = [ALCRuntimeScanner modelScanner];
    XCTAssertTrue(scanner.selector([NSString class]));
}

-(void) testModelScannerIgnoresNonModelClass {

    [self setupMockContext];

    ALCRuntimeScanner *scanner = [ALCRuntimeScanner modelScanner];
    scanner.processor((id)self.mockContext, [NSMutableSet set], [NSString class]);

    OCMVerifyAll(self.mockContext);
}

-(void) testModelScannerProcessesModelClass {

    [self setupMockContext];

    id mockBuilder = OCMClassMock([ALCBuilder class]);
    OCMExpect([self.mockContext registerBuilderForClass:[ModelObject class]]).andReturn(mockBuilder);
    OCMExpect([self.mockContext classBuilderDidFinishRegistering:mockBuilder]);

    ALCRuntimeScanner *scanner = [ALCRuntimeScanner modelScanner];
    scanner.processor((id)self.mockContext, [NSMutableSet set], [ModelObject class]);

    OCMVerifyAll(self.mockContext);
}

@end
