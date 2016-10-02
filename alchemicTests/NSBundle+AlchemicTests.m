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
    
    id mockBundle = OCMClassMock([NSBundle class]);
    
    OCMStub(ClassMethod([mockBundle allBundles])).andReturn(@[mockBundle]);

    // Getting frameworks dir id.
    id mockURL = OCMClassMock([NSURL class]);
    OCMStub([mockBundle privateFrameworksURL]).andReturn(mockURL);
    OCMStub([mockURL getResourceValue:[OCMArg setTo:@"abc"] forKey:NSURLFileResourceIdentifierKey error:nil]).andReturn(YES);

    // Getting the ids of the directory of the framework.
    OCMStub(ClassMethod([mockBundle allFrameworks])).andReturn(@[mockBundle]);
    OCMStub([mockBundle bundleURL]).andReturn(mockURL);
    OCMStub([mockURL getResourceValue:[OCMArg setTo:mockURL] forKey:NSURLParentDirectoryURLKey error:nil]).andReturn(YES);
    
    // Test
    NSSet<NSBundle *> *bundles = [NSBundle scannableBundles];

    // Stop mocking class methods.
    [mockBundle stopMocking];

    XCTAssertEqual(2u, bundles.count);

    NSBundle *alchemicsBundle = [NSBundle bundleForClass:[Alchemic class]];
    XCTAssertTrue([bundles containsObject:mockBundle]);
    XCTAssertTrue([bundles containsObject:alchemicsBundle]);

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
