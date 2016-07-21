//
//  NSBundle+AlchemicTests.m
//  alchemic
//
//  Created by Derek Clarkson on 21/07/2016.
//  Copyright © 2016 Derek Clarkson. All rights reserved.
//

@import XCTest;
@import Alchemic;
@import Alchemic.Private;
@import OCMock;

@interface NSBundle_AlchemicTests : XCTestCase
@end

@implementation NSBundle_AlchemicTests

-(void) testScanWithProcessors {
    
    NSBundle *thisBundle = [NSBundle bundleForClass:[self class]];
    id contextMock = OCMProtocolMock(@protocol(ALCContext));
    
    id canProcessMock = OCMProtocolMock(@protocol(ALCClassProcessor));
    OCMStub([canProcessMock canProcessClass:OCMOCK_ANY]).andReturn(YES);
    OCMExpect([canProcessMock processClass:OCMOCK_ANY withContext:contextMock]);
    
    id cantProcessMock = OCMProtocolMock(@protocol(ALCClassProcessor));
    
    __block unsigned int foundClasses = 0;
    OCMStub([cantProcessMock canProcessClass:[OCMArg checkWithBlock:^BOOL(id obj) {
        foundClasses++;
        return YES;
    }]]).andReturn(NO);
    
    
    [thisBundle scanWithProcessors:@[
                                     canProcessMock,
                                     cantProcessMock
                                     ]
                           context:contextMock];
    
    unsigned int nbrClasses = 0;
    __unused const char** classes = objc_copyClassNamesForImage([[thisBundle executablePath] UTF8String], &nbrClasses);
    
    OCMVerifyAll(canProcessMock);
    XCTAssertEqual(nbrClasses, foundClasses);
    
}

@end
