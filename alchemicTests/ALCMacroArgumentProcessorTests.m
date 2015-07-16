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

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wundeclared-selector"

@implementation ALCMacroArgumentProcessorTests {
    ALCMacroArgumentProcessor *_processor;
    ALCQualifier *_stringQ;
    ALCQualifier *_classQ;
    ALCQualifier *_protocolQ;

    NSString *_stringVar;
    NSNumber *_numberVar;
}

-(void) setUp {
    _stringQ = [ALCQualifier qualifierWithValue:@"abc"];
    _classQ = [ALCQualifier qualifierWithValue:[self class]];
    _protocolQ = [ALCQualifier qualifierWithValue:@protocol(NSCopying)];
    _processor = [[ALCMacroArgumentProcessor alloc] initWithParentClass:[self class]];
}

-(void) testSetsIsFactoryFlag {
    [self processArguments:ACIsFactory, nil];
    XCTAssertTrue(_processor.isFactory);
}

-(void) testSetsIsPrimaryFlag {
    [self processArguments:ACIsPrimary, nil];
    XCTAssertTrue(_processor.isPrimary);
}

-(void) testSetsName {
    [self processArguments:ACAsName(@"abc"), nil];
    XCTAssertEqualObjects(@"abc", _processor.asName);
}

-(void) testSetsVariableName {
    [self processArguments:ACIntoVariable(abc), nil];
    XCTAssertEqualObjects(@"abc", _processor.variableName);
}

-(void) testSetsSelector {
    [self processArguments:ACSelector(testSetsSelector), nil];
    XCTAssertEqual(@selector(testSetsSelector), _processor.selector);
}

-(void) testSetsReturnType {
    [self processArguments:ACReturnType(self), nil];
    XCTAssertEqual([self class], _processor.returnType);
}

-(void) testClassRegistrationSetsDefaultName {
    [self processArguments:nil];
    [_processor validate];
    XCTAssertEqualObjects(NSStringFromClass([self class]), _processor.asName);
}

-(void) testClassRegistrationWithValuesThrows {
    [self processArguments:ACWithValue(@12), nil];
    XCTAssertThrowsSpecificNamed([_processor validate], NSException, @"AlchemicInvalidRegistration");
}

-(void) testDependencyWithConstantValue {
    [self processArguments:ACIntoVariable(_numberVar), ACWithValue(@12), nil];
    [_processor validate];
    id<ALCValueSource> valueSource = [_processor dependencyValueSource];
    XCTAssertEqualObjects(@12, valueSource.values.anyObject);
}

-(void) testDependencyWithConstantAndOtherMacrosThrows {
    [self processArguments:ACIntoVariable(_numberVar), ACWithValue(@12), ACWithClass([self class]), nil];
    XCTAssertThrowsSpecificNamed([_processor validate], NSException, @"AlchemicInvalidArguments");
}

-(void) testDependencyWithModelValueSource {
    [self processArguments:ACIntoVariable(_stringVar), _stringQ, _classQ, _protocolQ, nil];
    [_processor validate];
    ALCModelValueSource *valueSource = [_processor dependencyValueSource];
    NSSet<id<ALCModelSearchExpression>> *searchExpressions = valueSource.searchExpressions;
    XCTAssertTrue([searchExpressions containsObject:_stringQ]);
    XCTAssertTrue([searchExpressions containsObject:_classQ]);
    XCTAssertTrue([searchExpressions containsObject:_protocolQ]);
}

-(void) testDependencyWithArrayArgumentThrows {
    [self processArguments:ACIntoVariable(_stringVar), _stringQ, @[_classQ, _protocolQ], nil];
    XCTAssertThrowsSpecificNamed([_processor validate], NSException, @"AlchemicUnexpectedArray");
}

-(void) testMethodWithModelSourceValueSources {
    [self processArguments:ACSelector(methodWithString:class:protocol:), _stringQ, _classQ, _protocolQ, nil];
    [_processor validate];
    NSArray<id<ALCValueSource>> *valueSources = [_processor methodValueSources];
    XCTAssertTrue([((ALCModelValueSource *)valueSources[0]).searchExpressions containsObject:_stringQ]);
    XCTAssertTrue([((ALCModelValueSource *)valueSources[1]).searchExpressions containsObject:_classQ]);
    XCTAssertTrue([((ALCModelValueSource *)valueSources[2]).searchExpressions containsObject:_protocolQ]);
}

-(void) testMethodWithTooFewArgumentsThrows {
    [self processArguments:ACSelector(methodWithString:class:protocol:), _stringQ, _classQ, nil];
    XCTAssertThrowsSpecificNamed([_processor validate], NSException, @"AlchemicIncorrectNumberArguments");
}

-(void) testMethodWithTooManyArgumentsThrows {
    [self processArguments:ACSelector(methodWithString:class:protocol:), _stringQ, _classQ, _protocolQ, ACWithValue(@"abc"), nil];
    XCTAssertThrowsSpecificNamed([_processor validate], NSException, @"AlchemicIncorrectNumberArguments");
}

-(void) testMethodWhenSelectorLast {
    [self processArguments:_stringQ, _classQ, _protocolQ, ACSelector(methodWithString:class:protocol:), nil];
    [_processor validate];
    NSArray<id<ALCValueSource>> *valueSources = [_processor methodValueSources];
    XCTAssertTrue([((ALCModelValueSource *)valueSources[0]).searchExpressions containsObject:_stringQ]);
    XCTAssertTrue([((ALCModelValueSource *)valueSources[1]).searchExpressions containsObject:_classQ]);
    XCTAssertTrue([((ALCModelValueSource *)valueSources[2]).searchExpressions containsObject:_protocolQ]);
}

-(void) testMethodWithArraysOfQualifiers {
    [self processArguments:ACSelector(methodWithString:runtime:), _stringQ, @[_classQ, _protocolQ], nil];
    [_processor validate];
    NSArray<id<ALCValueSource>> *valueSources = [_processor methodValueSources];
    XCTAssertTrue([((ALCModelValueSource *)valueSources[0]).searchExpressions containsObject:_stringQ]);
    XCTAssertTrue([((ALCModelValueSource *)valueSources[1]).searchExpressions containsObject:_classQ]);
    XCTAssertTrue([((ALCModelValueSource *)valueSources[1]).searchExpressions containsObject:_protocolQ]);
}

-(void) testMethodWithArraysOfQualifiersAndConstants {
    [self processArguments:ACSelector(methodWithString:runtime:), ACWithValue(@"abc"), @[_classQ, _protocolQ], nil];
    [_processor validate];

    NSArray<id<ALCValueSource>> *valueSources = [_processor methodValueSources];
    XCTAssertEqualObjects(@"abc", valueSources[0].values.anyObject);
    XCTAssertTrue([((ALCModelValueSource *)valueSources[1]).searchExpressions containsObject:_classQ]);
    XCTAssertTrue([((ALCModelValueSource *)valueSources[1]).searchExpressions containsObject:_protocolQ]);
}

-(void) testMethodSetsDefaultName {
    [self processArguments:ACSelector(testMethodSetsDefaultName), nil];
    [_processor validate];
    XCTAssertEqualObjects(@"ALCMacroArgumentProcessorTests::testMethodSetsDefaultName", _processor.asName);
}


-(void) testValidateSelectorValid {
    [_processor addArgument:ACSelector(testValidateSelectorValid)];
    [_processor validate];
}

-(void) testValidateSelectorInValid {
    [_processor addArgument:ACSelector(xxxx)];
    XCTAssertThrowsSpecificNamed([_processor validate],
                                 NSException,
                                 @"AlchemicSelectorNotFound");
}

-(void) testFullMethodRegistration {
    [self processArguments:ACIsFactory, ACIsPrimary, ACAsName(@"abc"), ACReturnType(NSObject), ACSelector(methodWithObject:), ACWithClass(self), nil];
    XCTAssertTrue(_processor.isFactory);
    XCTAssertTrue(_processor.isPrimary);
    XCTAssertEqualObjects(@"abc", _processor.asName);
    XCTAssertEqual([NSObject class], _processor.returnType);
    XCTAssertEqual(@selector(methodWithObject:), _processor.selector);
    NSArray<id<ALCValueSource>> *valueSources = [_processor methodValueSources];
    XCTAssertTrue([valueSources[0] isKindOfClass:[ALCModelValueSource class]]);
}

#pragma mark - Internal

-(void) processArguments:(id) firstArgument, ... {

    [_processor addArgument:firstArgument];

    va_list args;
    va_start(args, firstArgument);
    id arg;
    while ((arg = va_arg(args, id)) != nil) {
        [_processor addArgument:arg];
    }
    va_end(args);
}

-(id) methodWithObject:(id) object {
    return nil;
}

-(id) methodWithString:(NSString *) aString class:(Class) aClass protocol:(Protocol *) aProtocol {
    return nil;
}

-(id) methodWithString:(NSString *) aString runtime:(id) runtime {
    return nil;
}

@end

#pragma clang diagnostic pop
