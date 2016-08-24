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

-(void) testScannableBundles {

}

-(void) testScanWithProcessors {
    
    NSBundle *thisBundle = [NSBundle bundleForClass:[self class]];
    id mockContext = OCMProtocolMock(@protocol(ALCContext));
    
    id mockClassProcessor1 = OCMProtocolMock(@protocol(ALCClassProcessor));
    OCMStub([mockClassProcessor1 canProcessClass:OCMOCK_ANY]).andReturn(YES);
    OCMExpect([mockClassProcessor1 processClass:OCMOCK_ANY withContext:mockContext]);
    
    id mockClassProcessor2 = OCMProtocolMock(@protocol(ALCClassProcessor));
    
    __block unsigned int checkedClasses = 0;
    OCMStub([mockClassProcessor2 canProcessClass:[OCMArg checkWithBlock:^BOOL(id obj) {
        checkedClasses++;
        return YES;
    }]]).andReturn(NO);

    [thisBundle scanWithProcessors:@[
                                     mockClassProcessor1,
                                     mockClassProcessor2
                                     ]
                           context:mockContext];

    OCMVerifyAll(mockClassProcessor1);
    XCTAssertEqual([self nbrClassesInBundle:thisBundle], checkedClasses);
    
}

-(unsigned int) nbrClassesInBundle:(NSBundle *) bundle {
    unsigned int nbrClasses = 0;
    const char** classes = objc_copyClassNamesForImage([[bundle executablePath] UTF8String], &nbrClasses);
    free(classes);
    return nbrClasses;
}

@end
