//
//  ALCMacroArgumentProcessorTests.m
//  Alchemic
//
//  Created by Derek Clarkson on 15/07/2015.
//  Copyright © 2015 Derek Clarkson. All rights reserved.
//
#import "ALCTestCase.h"
#import <Alchemic/Alchemic.h>

#import "ALCMethodRegistrationMacroProcessor.h"
#import "ALCModelValueSource.h"
#import "ALCModelSearchExpression.h"
#import "ALCQualifier+Internal.h"
#import "ALCValueSource.h"

@interface ALCMethodRegistrationMacroProcessorTests : ALCTestCase

@end

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wundeclared-selector"

#define setupProcessorForSelector(selectorSig) \
_processor = [[ALCMethodRegistrationMacroProcessor alloc] initWithParentClass:[self class] \
selector:@selector(selectorSig) \
returnType:[NSObject class]]

@implementation ALCMethodRegistrationMacroProcessorTests {
    ALCMethodRegistrationMacroProcessor *_processor;
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
}


-(void) testSetsIsFactoryFlag {
    setupProcessorForSelector(method);
    [self loadMacroProcessor:_processor withArguments:ACIsFactory, nil];
    XCTAssertTrue(_processor.isFactory);
}

-(void) testSetsIsPrimaryFlag {
    setupProcessorForSelector(method);
    [self loadMacroProcessor:_processor withArguments:ACIsPrimary, nil];
    XCTAssertTrue(_processor.isPrimary);
}

-(void) testSetsName {
    setupProcessorForSelector(method);
    [self loadMacroProcessor:_processor withArguments:ACAsName(@"abc"), nil];
    XCTAssertEqualObjects(@"abc", _processor.asName);
}

-(void) testSetsSelector {
    setupProcessorForSelector(method);
    XCTAssertEqual(@selector(method), _processor.selector);
}

-(void) testSetsReturnType {
    setupProcessorForSelector(method);
    XCTAssertEqual([NSObject class], _processor.returnType);
}

-(void) testMethodWithModelSourceValueSources {
    setupProcessorForSelector(methodWithString:class:protocol:);
    [self loadMacroProcessor:_processor withArguments:_stringQ, _classQ, _protocolQ, nil];
    NSArray<id<ALCValueSource>> *valueSources = [_processor methodValueSources];
    XCTAssertTrue([((ALCModelValueSource *)valueSources[0]).searchExpressions containsObject:_stringQ]);
    XCTAssertTrue([((ALCModelValueSource *)valueSources[1]).searchExpressions containsObject:_classQ]);
    XCTAssertTrue([((ALCModelValueSource *)valueSources[2]).searchExpressions containsObject:_protocolQ]);
}

-(void) testMethodWithTooFewArgumentsThrows {
    setupProcessorForSelector(methodWithString:class:protocol:);
    XCTAssertThrowsSpecificNamed(([self loadMacroProcessor:_processor withArguments:_stringQ, _classQ, nil]), NSException, @"AlchemicIncorrectNumberArguments");
}

-(void) testMethodWithTooManyArgumentsThrows {
    setupProcessorForSelector(methodWithString:class:protocol:);
    XCTAssertThrowsSpecificNamed(([self loadMacroProcessor:_processor withArguments:_stringQ, _classQ, _protocolQ, ACWithValue(@"abc"), nil]), NSException, @"AlchemicIncorrectNumberArguments");
}

-(void) testMethodWithArraysOfQualifiers {
    setupProcessorForSelector(methodWithString:runtime:);
    [self loadMacroProcessor:_processor withArguments:_stringQ, @[_classQ, _protocolQ], nil];
    NSArray<id<ALCValueSource>> *valueSources = [_processor methodValueSources];
    XCTAssertTrue([((ALCModelValueSource *)valueSources[0]).searchExpressions containsObject:_stringQ]);
    XCTAssertTrue([((ALCModelValueSource *)valueSources[1]).searchExpressions containsObject:_classQ]);
    XCTAssertTrue([((ALCModelValueSource *)valueSources[1]).searchExpressions containsObject:_protocolQ]);
}

-(void) testMethodWithArraysOfQualifiersAndConstants {
    setupProcessorForSelector(methodWithString:runtime:);
    [self loadMacroProcessor:_processor withArguments:ACWithValue(@"abc"), @[_classQ, _protocolQ], nil];

    NSArray<id<ALCValueSource>> *valueSources = [_processor methodValueSources];
    XCTAssertEqualObjects(@"abc", valueSources[0].values.anyObject);
    XCTAssertTrue([((ALCModelValueSource *)valueSources[1]).searchExpressions containsObject:_classQ]);
    XCTAssertTrue([((ALCModelValueSource *)valueSources[1]).searchExpressions containsObject:_protocolQ]);
}

-(void) testMethodSetsDefaultName {
    setupProcessorForSelector(method);
    [_processor validate];
    XCTAssertEqualObjects(@"ALCMethodRegistrationMacroProcessorTests::method", _processor.asName);
}


-(void) testValidateSelectorInValid {
    setupProcessorForSelector(xxxx);
    XCTAssertThrowsSpecificNamed([_processor validate], NSException, @"AlchemicSelectorNotFound");
}

-(void) testFullMethodRegistration {
    setupProcessorForSelector(methodWithObject:);
    [self loadMacroProcessor:_processor withArguments:ACIsFactory, ACIsPrimary, ACAsName(@"abc"), ACWithClass(self), nil];
    XCTAssertTrue(_processor.isFactory);
    XCTAssertTrue(_processor.isPrimary);
    XCTAssertEqualObjects(@"abc", _processor.asName);
    XCTAssertEqual([NSObject class], _processor.returnType);
    XCTAssertEqual(@selector(methodWithObject:), _processor.selector);
    NSArray<id<ALCValueSource>> *valueSources = [_processor methodValueSources];
    XCTAssertTrue([valueSources[0] isKindOfClass:[ALCModelValueSource class]]);
}

#pragma mark - Internal

-(id) method {
    return nil;
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
