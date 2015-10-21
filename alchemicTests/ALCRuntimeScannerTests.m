//
//  ALCRuntimeScannerTests.m
//  alchemic
//
//  Created by Derek Clarkson on 20/10/2015.
//  Copyright © 2015 Derek Clarkson. All rights reserved.
//

#import <XCTest/XCTest.h>
@import ObjectiveC;
#import <OCMock/OCMock.h>

#import "ALCRuntimeScanner.h"
#import "ALCContext.h"

@interface ALCRuntimeScannerTests : XCTestCase

@end

@implementation ALCRuntimeScannerTests

-(void) testSwiftScanner {

    id mockContext = OCMClassMock([ALCContext class]);
    ALCRuntimeScanner *scanner = [ALCRuntimeScanner swiftScanner];

    NSArray<NSBundle *> *appBundles = [NSBundle allBundles];
    [appBundles enumerateObjectsUsingBlock:^(NSBundle *bundle, NSUInteger idx, BOOL *stop) {

        unsigned int count = 0;
        const char** classes = objc_copyClassNamesForImage([[bundle executablePath] UTF8String], &count);

        for(unsigned int i = 0;i < count;i++) {

            Class nextClass = objc_getClass(classes[i]);
            if ([NSStringFromClass(nextClass) containsString:@"Swift"]) {
                NSLog(@"Class: %@", NSStringFromClass(nextClass));
                scanner.processor(mockContext, [NSMutableSet set], nextClass);
            }
        }
    }];
}

@end
