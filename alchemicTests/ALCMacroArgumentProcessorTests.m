//
//  ALCMacroArgumentProcessorTests.m
//  Alchemic
//
//  Created by Derek Clarkson on 15/07/2015.
//  Copyright © 2015 Derek Clarkson. All rights reserved.
//

@import XCTest;
#import "ALCMacroArgumentProcessor.h"
#import <Alchemic/Alchemic.h>
#import "ALCModelValueSource.h"
#import "ALCModelSearchExpression.h"
#import "ALCQualifier+Internal.h"
#import "ALCValueSource.h"

@interface ALCMacroArgumentProcessorTests : XCTestCase

@end

@implementation ALCMacroArgumentProcessorTests {
    ALCMacroArgumentProcessor *_processor;
    ALCQualifier *_stringQ;
    ALCQualifier *_classQ;
    ALCQualifier *_protocolQ;
}

-(void) setUp {
    _stringQ = [ALCQualifier qualifierWithValue:@"abc"];
    _classQ = [ALCQualifier qualifierWithValue:[self class]];
    _protocolQ = [ALCQualifier qualifierWithValue:@protocol(NSCopying)];
    _processor = [[ALCMacroArgumentProcessor alloc] init];
}

-(void) testSetsIsFactoryFlag {
    [_processor processArgument:[[ALCIsFactory alloc] init]];
    XCTAssertTrue(_processor.isFactory);
}

-(void) testSetsIsPrimaryFlag {
    [_processor processArgument:[[ALCIsPrimary alloc] init]];
    XCTAssertTrue(_processor.isPrimary);
}

-(void) testSetsName {
    [_processor processArgument:[ALCAsName asNameWithName:@"abc"]];
    XCTAssertEqualObjects(@"abc", _processor.asName);
}

-(void) testSetsVariableName {
    [_processor processArgument:[ALCIntoVariable intoVariableWithName:@"abc"]];
    XCTAssertEqualObjects(@"abc", _processor.variableName);
}

-(void) testSetsSelector {
    [_processor processArgument:[ALCMethodSelector methodSelector:@selector(testSetsSelector)]];
    XCTAssertEqual(@selector(testSetsSelector), _processor.selector);
}

-(void) testSetsReturnType {
    [_processor processArgument:[ALCReturnType returnTypeWithClass:[self class]]];
    XCTAssertEqual([self class], _processor.returnType);
}

-(void) testSetsConstantValue {
    [_processor processArgument:[ALCConstantValue constantValueWithValue:@12]];
    [_processor validateWithClass:[self class]];
    id<ALCValueSource> valueSource = [_processor dependencyValueSource];
    XCTAssertEqualObjects(@12, valueSource.values.anyObject);
}

-(void) testCreatesDependencyValueSource {
    [_processor processArgument:_stringQ];
    [_processor processArgument:_classQ];
    [_processor processArgument:_protocolQ];
    [_processor validateWithClass:[self class]];
    ALCModelValueSource *valueSource = [_processor dependencyValueSource];
    NSSet<id<ALCModelSearchExpression>> *searchExpressions = valueSource.searchExpressions;
    XCTAssertTrue([searchExpressions containsObject:_stringQ]);
    XCTAssertTrue([searchExpressions containsObject:_classQ]);
    XCTAssertTrue([searchExpressions containsObject:_protocolQ]);
}

-(void) testCreatesMethodArgumentValueSources {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wundeclared-selector"
    [_processor processArgument:[ALCMethodSelector methodSelector:@selector(methodWithString:class:protocol:)]];
    [_processor processArgument:_stringQ];
    [_processor processArgument:_classQ];
    [_processor processArgument:_protocolQ];
    [_processor validateWithClass:[self class]];
    NSSet<id<ALCModelSearchExpression>> *searchExpressions;
    searchExpressions = ((ALCModelValueSource *)[_processor valueSourceAtIndex:0]).searchExpressions;
    XCTAssertTrue([searchExpressions containsObject:_stringQ]);
    searchExpressions = ((ALCModelValueSource *)[_processor valueSourceAtIndex:1]).searchExpressions;
    XCTAssertTrue([searchExpressions containsObject:_classQ]);
    searchExpressions = ((ALCModelValueSource *)[_processor valueSourceAtIndex:2]).searchExpressions;
    XCTAssertTrue([searchExpressions containsObject:_protocolQ]);
#pragma clang diagnostic pop
}

-(void) testCreatesMethodArgumentValueSourcesWhenSelectorLast {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wundeclared-selector"
    [_processor processArgument:_stringQ];
    [_processor processArgument:_classQ];
    [_processor processArgument:_protocolQ];
    [_processor processArgument:[ALCMethodSelector methodSelector:@selector(methodWithString:class:protocol:)]];
    [_processor validateWithClass:[self class]];
    NSSet<id<ALCModelSearchExpression>> *searchExpressions;
    searchExpressions = ((ALCModelValueSource *)[_processor valueSourceAtIndex:0]).searchExpressions;
    XCTAssertTrue([searchExpressions containsObject:_stringQ]);
    searchExpressions = ((ALCModelValueSource *)[_processor valueSourceAtIndex:1]).searchExpressions;
    XCTAssertTrue([searchExpressions containsObject:_classQ]);
    searchExpressions = ((ALCModelValueSource *)[_processor valueSourceAtIndex:2]).searchExpressions;
    XCTAssertTrue([searchExpressions containsObject:_protocolQ]);
#pragma clang diagnostic pop
}

-(void) testStoresMethodSearchExpressionsHandlesArraysOfQualifiers {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wundeclared-selector"
    [_processor processArgument:_stringQ];
    [_processor processArgument:@[_classQ, _protocolQ]];
    [_processor processArgument:[ALCMethodSelector methodSelector:@selector(methodWithString:runtime:)]];
    [_processor validateWithClass:[self class]];
    XCTAssertEqualObjects(_stringQ, [_processor searchExpressionsAtIndex:0].anyObject);
    NSSet<id<ALCModelSearchExpression>> *quals = [_processor searchExpressionsAtIndex:1];
    XCTAssertTrue([quals containsObject:_classQ]);
    XCTAssertTrue([quals containsObject:_protocolQ]);
#pragma clang diagnostic pop
}

-(void) testStoresSearchExpressionsThrowsWhenArrayPresent {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wundeclared-selector"
    [_processor processArgument:_stringQ];
    [_processor processArgument:@[_classQ, _protocolQ]];
    XCTAssertThrowsSpecificNamed([_processor validateWithClass:[self class]], NSException, @"AlchemicUnexpectedArray");
#pragma clang diagnostic pop
}

-(void) testValidateSelectorValid {
    [_processor processArgument:[ALCMethodSelector methodSelector:@selector(testValidateSelectorValid)]];
    [_processor validateWithClass:[self class]];
}

-(void) testValidateSelectorInValid {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wundeclared-selector"
    [_processor processArgument:[ALCMethodSelector methodSelector:@selector(xxxx)]];
    XCTAssertThrowsSpecificNamed([_processor validateWithClass:[self class]],
                                 NSException,
                                 @"AlchemicSelectorNotFound");
#pragma clang diagnostic pop
}


@end
