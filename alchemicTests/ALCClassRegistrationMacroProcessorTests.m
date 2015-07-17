//
//  ALCMacroArgumentProcessorTests.m
//  Alchemic
//
//  Created by Derek Clarkson on 15/07/2015.
//  Copyright © 2015 Derek Clarkson. All rights reserved.
//
#import "ALCTestCase.h"

#import "ALCClassRegistrationMacroProcessor.h"
#import <Alchemic/Alchemic.h>
#import "ALCModelValueSource.h"
#import "ALCModelSearchExpression.h"
#import "ALCValueSource.h"

@interface ALCClassRegistrationMacroProcessorTests : ALCTestCase

@end

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wundeclared-selector"

@implementation ALCClassRegistrationMacroProcessorTests {
    ALCClassRegistrationMacroProcessor *_processor;
}

-(void) setUp {
    _processor = [[ALCClassRegistrationMacroProcessor alloc] initWithParentClass:[self class]];
}

-(void) testSetsIsFactoryFlag {
    [self loadMacroProcessor:_processor withArguments:ACIsFactory, nil];
    XCTAssertTrue(_processor.isFactory);
}

-(void) testSetsIsPrimaryFlag {
    [self loadMacroProcessor:_processor withArguments:ACIsPrimary, nil];
    XCTAssertTrue(_processor.isPrimary);
}

-(void) testSetsName {
    [self loadMacroProcessor:_processor withArguments:ACAsName(@"abc"), nil];
    XCTAssertEqualObjects(@"abc", _processor.asName);
}

-(void) testClassRegistrationSetsDefaultName {
    [self loadMacroProcessor:_processor withArguments:nil];
    XCTAssertEqualObjects(NSStringFromClass([self class]), _processor.asName);
}

-(void) testClassRegistrationUnknownMacro {
    XCTAssertThrowsSpecificNamed(([self loadMacroProcessor:_processor withArguments:ACWithValue(@12), nil]), NSException, @"AlchemicUnexpectedMacro");
}

@end

#pragma clang diagnostic pop
