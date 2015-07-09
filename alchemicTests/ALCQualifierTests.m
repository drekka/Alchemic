//
//  ALCQualifierTests.m
//  Alchemic
//
//  Created by Derek Clarkson on 6/07/2015.
//  Copyright © 2015 Derek Clarkson. All rights reserved.

//

@import XCTest;
#import <OCMock/OCMock.h>
#import <Alchemic/Alchemic.h>
#import <StoryTeller/StoryTeller.h>

#import "ALCQualifier.h"
#import "ALCClassBuilder.h"


@interface ALCQualifierTests : XCTestCase
@end

@implementation ALCQualifierTests {
    id _mockContext;
    id<ALCBuilder> _builder;
}

-(void) setUp {
    _mockContext = OCMClassMock([ALCContext class]);
    _builder = [[ALCClassBuilder alloc] initWithContext:_mockContext
                                                           valueClass:[NSString class]
                                                                 name:@"abc"];
}

-(void) testStringQualifierMatches {
    ALCQualifier *qualifier = [ALCQualifier qualifierWithValue:@"abc"];
    XCTAssertTrue([qualifier matchesBuilder:_builder]);
}

-(void) testStringQualifierFailsMatch {
    ALCQualifier *qualifier = [ALCQualifier qualifierWithValue:@"def"];
    XCTAssertFalse([qualifier matchesBuilder:_builder]);
}

-(void) testClassQualifierMatches {
    STStartLogging(@"is [NSString]");
    ALCQualifier *qualifier = [ALCQualifier qualifierWithValue:[NSString class]];
    XCTAssertTrue([qualifier matchesBuilder:_builder]);
}

-(void) testClassQualifierFailsMatch {
    ALCQualifier *qualifier = [ALCQualifier qualifierWithValue:[NSArray class]];
    XCTAssertFalse([qualifier matchesBuilder:_builder]);
}

-(void) testProtocolQualifierMatches {
    ALCQualifier *qualifier = [ALCQualifier qualifierWithValue:@protocol(NSCopying)];
    XCTAssertTrue([qualifier matchesBuilder:_builder]);
}

-(void) testProtocolQualifierFailsMatch {
    ALCQualifier *qualifier = [ALCQualifier qualifierWithValue:@protocol(NSFastEnumeration)];
    XCTAssertFalse([qualifier matchesBuilder:_builder]);
}

@end
