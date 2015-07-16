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
#import "ALCTestCase.h"

#import "ALCQualifier.h"
#import "ALCClassBuilder.h"
#import "ALCQualifier+Internal.h"


@interface ALCQualifierTests : ALCTestCase
@end

@implementation ALCQualifierTests {
    id _mockContext;
    id<ALCBuilder> _builder;
}

-(void) setUp {
    [super setUp];
    _mockContext = OCMClassMock([ALCContext class]);
    _builder = [[ALCClassBuilder alloc] initWithValueClass:[NSString class]
                                                      name:@"abc"];
}

-(void) testStringQualifierMatches {
    ALCQualifier *qualifier = [ALCQualifier qualifierWithValue:@"abc"];
    XCTAssertTrue(qualifier.matchBlock(_builder));
}

-(void) testStringQualifierFailsMatch {
    ALCQualifier *qualifier = [ALCQualifier qualifierWithValue:@"def"];
    XCTAssertFalse(qualifier.matchBlock(_builder));
}

-(void) testClassQualifierMatches {
    STStartLogging(@"is [NSString]");
    ALCQualifier *qualifier = [ALCQualifier qualifierWithValue:[NSString class]];
    XCTAssertTrue(qualifier.matchBlock(_builder));
}

-(void) testClassQualifierFailsMatch {
    ALCQualifier *qualifier = [ALCQualifier qualifierWithValue:[NSArray class]];
    XCTAssertFalse(qualifier.matchBlock(_builder));
}

-(void) testProtocolQualifierMatches {
    ALCQualifier *qualifier = [ALCQualifier qualifierWithValue:@protocol(NSCopying)];
    XCTAssertTrue(qualifier.matchBlock(_builder));
}

-(void) testProtocolQualifierFailsMatch {
    ALCQualifier *qualifier = [ALCQualifier qualifierWithValue:@protocol(NSFastEnumeration)];
    XCTAssertFalse(qualifier.matchBlock(_builder));
}

#pragma mark - Equality & hash

-(void) testIsEqualToQualifierWhenSameInstance {
    ALCQualifier *qualifier1 = [ALCQualifier qualifierWithValue:[NSString class]];
    XCTAssertTrue([qualifier1 isEqualToQualifier:qualifier1]);
    XCTAssertEqual([qualifier1 hash], [qualifier1 hash]);
}

-(void) testIsEqualToQualifierWhenSameClass {
    ALCQualifier *qualifier1 = [ALCQualifier qualifierWithValue:[NSString class]];
    ALCQualifier *qualifier2 = [ALCQualifier qualifierWithValue:[NSString class]];
    XCTAssertTrue([qualifier1 isEqualToQualifier:qualifier2]);
    XCTAssertEqual([qualifier1 hash], [qualifier2 hash]);
}

-(void) testIsEqualToQualifierWhenSameProtocol {
    ALCQualifier *qualifier1 = [ALCQualifier qualifierWithValue:@protocol(NSCopying)];
    ALCQualifier *qualifier2 = [ALCQualifier qualifierWithValue:@protocol(NSCopying)];
    XCTAssertTrue([qualifier1 isEqualToQualifier:qualifier2]);
    XCTAssertEqual([qualifier1 hash], [qualifier2 hash]);
}

-(void) testIsEqualToQualifierWhenSameString {
    ALCQualifier *qualifier1 = [ALCQualifier qualifierWithValue:@"abc"];
    ALCQualifier *qualifier2 = [ALCQualifier qualifierWithValue:@"abc"];
    XCTAssertTrue([qualifier1 isEqualToQualifier:qualifier2]);
    XCTAssertEqual([qualifier1 hash], [qualifier2 hash]);
}

-(void) testIsEqualToQualifierWhenDifferentClasses {
    ALCQualifier *qualifier1 = [ALCQualifier qualifierWithValue:[NSString class]];
    ALCQualifier *qualifier2 = [ALCQualifier qualifierWithValue:[NSMutableString class]];
    XCTAssertFalse([qualifier1 isEqualToQualifier:qualifier2]);
    XCTAssertNotEqual([qualifier1 hash], [qualifier2 hash]);
}

-(void) testIsEqualToQualifierWhenDifferentTypes {
    ALCQualifier *qualifier1 = [ALCQualifier qualifierWithValue:[NSString class]];
    ALCQualifier *qualifier2 = [ALCQualifier qualifierWithValue:@protocol(NSCopying)];
    XCTAssertFalse([qualifier1 isEqualToQualifier:qualifier2]);
    XCTAssertNotEqual([qualifier1 hash], [qualifier2 hash]);
}


@end
