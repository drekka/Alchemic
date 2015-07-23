//
//  ALCMacroArgumentProcessorTests.m
//  Alchemic
//
//  Created by Derek Clarkson on 15/07/2015.
//  Copyright © 2015 Derek Clarkson. All rights reserved.
//
#import "ALCTestCase.h"
#import <Alchemic/Alchemic.h>

#import "ALCMethodMacroProcessor.h"
#import "ALCModelValueSource.h"
#import "ALCModelSearchExpression.h"
#import "ALCValueSource.h"

@interface ALCMethodRegistrationMacroProcessorTests : ALCTestCase

@end

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wundeclared-selector"

@implementation ALCMethodRegistrationMacroProcessorTests {
    ALCMethodMacroProcessor *_processor;
    ALCArg *_stringArg;
    ALCArg *_classArg;
    ALCArg *_protocolArg;
    Class _metaClass;
    Class _protocolClass;

    NSString *_stringVar;
    NSNumber *_numberVar;
}

-(void) setUp {
    _protocolClass = NSClassFromString(@"Protocol");
    _metaClass = object_getClass([NSString class]);
    _stringArg = [ALCArg argWithType:[NSString class] macros:[ALCName withName:@"abc"], nil];
    _classArg = [ALCArg argWithType:_metaClass macros:[ALCClass withClass:[self class]], nil];
    _protocolArg = [ALCArg argWithType:_protocolClass macros:[ALCProtocol withProtocol:@protocol(NSCopying)], nil];
}


-(void) testSetsIsFactoryFlag {
    _processor = [[ALCMethodMacroProcessor alloc] init];
    [self loadMacroProcessor:_processor withArguments:ACIsFactory, nil];
    XCTAssertTrue(_processor.isFactory);
}

-(void) testSetsIsPrimaryFlag {
    _processor = [[ALCMethodMacroProcessor alloc] init];
    [self loadMacroProcessor:_processor withArguments:ACIsPrimary, nil];
    XCTAssertTrue(_processor.isPrimary);
}

-(void) testSetsName {
    _processor = [[ALCMethodMacroProcessor alloc] init];
    [self loadMacroProcessor:_processor withArguments:ACWithName(@"abc"), nil];
    XCTAssertEqualObjects(@"abc", _processor.asName);
}

-(void) testSetsSelector {
    _processor = [[ALCMethodMacroProcessor alloc] init];
    XCTAssertEqual(@selector(method), _processor.selector);
}

-(void) testSetsReturnType {
    _processor = [[ALCMethodMacroProcessor alloc] init];
    XCTAssertEqual([NSObject class], _processor.returnType);
}

-(void) testMethodWithModelSourceValueSources {
    setupProcessorForSelector(methodWithString:class:protocol:);
    [self loadMacroProcessor:_processor withArguments:_stringArg, _classArg, _protocolArg, nil];
    NSArray<ALCArg *> *args = [_processor methodValueSources];
    XCTAssertEqualObjects(_stringArg, args[0]);
}

-(void) testMethodWithTooFewArgumentsThrows {
    setupProcessorForSelector(methodWithString:class:protocol:);
    XCTAssertThrowsSpecificNamed(([self loadMacroProcessor:_processor withArguments:_stringArg, _classArg, nil]), NSException, @"AlchemicIncorrectNumberArguments");
}

-(void) testMethodWithTooManyArgumentsThrows {
    setupProcessorForSelector(methodWithString:class:protocol:);
    XCTAssertThrowsSpecificNamed(([self loadMacroProcessor:_processor withArguments:_stringArg, _classArg, _protocolArg, _stringArg, nil]), NSException, @"AlchemicIncorrectNumberArguments");
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

#pragma mark - Internal

-(id) method {
    return nil;
}

-(id) methodWithObject:(id) object {
    return nil;
}

-(id) methodWithString:(NSString *) stringByName class:(NSNumber *) numberByClass protocol:(Protocol *) aProtocol {
    return nil;
}

-(id) methodWithString:(NSString *) aString runtime:(id) runtime {
    return nil;
}

@end

#pragma clang diagnostic pop
