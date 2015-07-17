//
//  ALCMacroArgumentProcessorTests.m
//  Alchemic
//
//  Created by Derek Clarkson on 15/07/2015.
//  Copyright © 2015 Derek Clarkson. All rights reserved.
//

#import "ALCTestCase.h"

#import "ALCVariableDependencyMacroProcessor.h"
#import <Alchemic/Alchemic.h>
#import "ALCQualifier+Internal.h"
#import "ALCModelValueSource.h"

@interface ALCVariableDependencyMacroProcessorTests : ALCTestCase
@end

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wundeclared-selector"

@implementation ALCVariableDependencyMacroProcessorTests {
    ALCVariableDependencyMacroProcessor *_processor;
    ALCQualifier *_stringQ;
    ALCQualifier *_classQ;
    ALCQualifier *_protocolQ;

    NSString *_stringVar;
}

-(void) setUp {
    _stringQ = [ALCQualifier qualifierWithValue:@"abc"];
    _classQ = [ALCQualifier qualifierWithValue:[self class]];
    _protocolQ = [ALCQualifier qualifierWithValue:@protocol(NSCopying)];
    _processor = [[ALCVariableDependencyMacroProcessor alloc] initWithParentClass:[self class] variable:@"_stringVar"];
}

-(void) testDependencyWithConstantValue {
    [self loadMacroProcessor:_processor withArguments:ACWithValue(@12), nil];
    id<ALCValueSource> valueSource = [_processor valueSource];
    XCTAssertEqualObjects(@12, valueSource.values.anyObject);
}

-(void) testDependencyWithConstantAndOtherMacrosThrows {
    XCTAssertThrowsSpecificNamed(([self loadMacroProcessor:_processor withArguments:ACWithValue(@12), ACWithClass([self class]), nil]), NSException, @"AlchemicInvalidArguments");
}

-(void) testDependencyWithModelValueSource {
    [self loadMacroProcessor:_processor withArguments:_stringQ, _classQ, _protocolQ, nil];
    ALCModelValueSource *valueSource = [_processor valueSource];
    NSSet<id<ALCModelSearchExpression>> *searchExpressions = valueSource.searchExpressions;
    XCTAssertTrue([searchExpressions containsObject:_stringQ]);
    XCTAssertTrue([searchExpressions containsObject:_classQ]);
    XCTAssertTrue([searchExpressions containsObject:_protocolQ]);
}

-(void) testDependencyWithArrayArgumentThrows {
    XCTAssertThrowsSpecificNamed(([self loadMacroProcessor:_processor withArguments:_stringQ, @[_classQ, _protocolQ], nil]), NSException, @"AlchemicUnexpectedMacro");
}

@end

#pragma clang diagnostic pop
