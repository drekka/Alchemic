//
//  STConfigTests.m
//  StoryTeller
//
//  Created by Derek Clarkson on 22/06/2015.
//  Copyright © 2015 Derek Clarkson. All rights reserved.
//

#import <XCTest/XCTest.h>
#import <OCMock/OCMock.h>
#import <StoryTeller/StoryTeller.h>
#import "STConfig.h"

#import "InMemoryLogger.h"

@interface STConfigTests : XCTestCase
@property (nonatomic, assign) BOOL booleanProperty;
@end

@implementation STConfigTests {
    id _mockProcessInfo;
}

-(void) tearDown {
    [_mockProcessInfo stopMocking];
}

-(void) testConfigWithDefault {

    // Test
    STConfig *config = [[STConfig alloc] init];
    STStoryTeller *mockStoryTeller = OCMClassMock([STStoryTeller class]);
    [config configure:mockStoryTeller];

    // Verify
    OCMVerify([mockStoryTeller setLogger:[OCMArg isKindOfClass:[STConsoleLogger class]]]);
}

-(void) testConfigReadsCommandLineArgs {

    [self stubProcessInfoArguments:@[@"loggerClass=InMemoryLogger", @"activeLogs=abc,def"]];

    // Test
    STConfig *config = [[STConfig alloc] init];
    STStoryTeller *mockStoryTeller = OCMClassMock([STStoryTeller class]);
    [config configure:mockStoryTeller];

    // Verify
    OCMVerify([mockStoryTeller setLogger:[OCMArg isKindOfClass:[InMemoryLogger class]]]);
    OCMVerify([mockStoryTeller startLogging:@"abc"]);
    OCMVerify([mockStoryTeller startLogging:@"def"]);
}

-(void) testConfigWithInvalidLoggerClass {

    [self stubProcessInfoArguments:@[@"loggerClass=STConsoleLogger"]];

    // Test
    STConfig *config = [[STConfig alloc] init];
    id mockStoryTeller = OCMClassMock([STStoryTeller class]);
    [config configure:mockStoryTeller];

    // Verify
    Class loggerClass = [STConsoleLogger class];
    OCMVerify([(STStoryTeller *)mockStoryTeller setLogger:[OCMArg isKindOfClass:loggerClass]]);
}

-(void) stubProcessInfoArguments:(NSArray<NSString *> *) args {
    _mockProcessInfo = OCMClassMock([NSProcessInfo class]);
    OCMStub(ClassMethod([_mockProcessInfo processInfo])).andReturn(_mockProcessInfo);
    OCMStub([(NSProcessInfo *)_mockProcessInfo arguments]).andReturn(args);
}

-(void) testReadingYESNOStringsAsBooleans {
    [self setValue:@"YES" forKeyPath:@"booleanProperty"];
    XCTAssertTrue(self.booleanProperty);
    [self setValue:@"NO" forKeyPath:@"booleanProperty"];
    XCTAssertFalse(self.booleanProperty);
}

-(void) testReadingTrueFalseStringsAsBooleans {
    [self setValue:@"true" forKeyPath:@"booleanProperty"];
    XCTAssertTrue(self.booleanProperty);
    [self setValue:@"false" forKeyPath:@"booleanProperty"];
    XCTAssertFalse(self.booleanProperty);
}

-(void) testReading10StringsAsBooleans {
    [self setValue:@"1" forKeyPath:@"booleanProperty"];
    XCTAssertTrue(self.booleanProperty);
    [self setValue:@"0" forKeyPath:@"booleanProperty"];
    XCTAssertFalse(self.booleanProperty);
}

@end
