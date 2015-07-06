//
//  ALCRuntimeTests.m
//  Alchemic
//
//  Created by Derek Clarkson on 6/07/2015.
//  Copyright © 2015 Derek Clarkson. All rights reserved.
//

@import XCTest;
@import ObjectiveC;

#import <Alchemic/Alchemic.h>

#import "ALCRuntime.h"

@interface ALCRuntimeTests : XCTestCase

@end

@implementation ALCRuntimeTests {
    NSString *_aStringVariable;
}

#pragma mark - Type checks

-(void) testObjectIsAClassWithStringClass {
    XCTAssertTrue([ALCRuntime objectIsAClass:[NSString class]]);
}

-(void) testObjectIsAClassWithOtherClass {
    XCTAssertTrue([ALCRuntime objectIsAClass:[NSNumber class]]);
}

-(void) testObjectIsAClassWithProtocol {
    XCTAssertFalse([ALCRuntime objectIsAClass:@protocol(NSCopying)]);
}

-(void) testObjectIsAClassWithStringObject {
    XCTAssertFalse([ALCRuntime objectIsAClass:@"abc"]);
}

-(void) testObjectIsAClassWithNumberObject {
    XCTAssertFalse([ALCRuntime objectIsAClass:@12]);
}

-(void) testObjectIsAProtocolWithStringClass {
    XCTAssertFalse([ALCRuntime objectIsAProtocol:[NSString class]]);
}

-(void) testObjectIsAProtocolWithOtherClass {
    XCTAssertFalse([ALCRuntime objectIsAProtocol:[NSNumber class]]);
}

-(void) testObjectIsAProtocolWithProtocol {
    XCTAssertTrue([ALCRuntime objectIsAProtocol:@protocol(NSCopying)]);
}

-(void) testObjectIsAProtocolWithStringObject {
    XCTAssertFalse([ALCRuntime objectIsAProtocol:@"abc"]);
}

-(void) testObjectIsAProtocolWithNumberObject {
    XCTAssertFalse([ALCRuntime objectIsAProtocol:@12]);
}

-(void) testClassIsKindOfClassStringString {
    XCTAssertTrue([ALCRuntime aClass:[NSString class] isKindOfClass:[NSString class]]);
}

-(void) testClassIsKindOfClassMutableStringString {
    XCTAssertTrue([ALCRuntime aClass:[NSMutableString class] isKindOfClass:[NSString class]]);
}

-(void) testClassIsKindOfClassStringMutableString {
    XCTAssertFalse([ALCRuntime aClass:[NSString class] isKindOfClass:[NSMutableString class]]);
}

-(void) testClassConformsToProtocolWhenConforming {
    XCTAssertTrue([ALCRuntime aClass:[NSString class] conformsToProtocol:@protocol(NSCopying)]);
}

-(void) testClassConformsToProtocolWhenNotConforming {
    XCTAssertFalse([ALCRuntime aClass:[NSString class] conformsToProtocol:@protocol(NSFastEnumeration)]);
}

#pragma mark - General

-(void) testAlchemicSelector {
    SEL alcSel = [ALCRuntime alchemicSelectorForSelector:@selector(testAlchemicSelector)];
    XCTAssertEqualObjects(@"_alchemic_testAlchemicSelector", NSStringFromSelector(@selector(testAlchemicSelector)));
}

-(void) testValidateSelectorValid {
    [ALCRuntime validateSelector:@selector(testValidateSelectorValid) withClass:[self class]];
}

-(void) testValidateSelectorInValid {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wundeclared-selector"
        XCTAssertThrowsSpecificNamed([ALCRuntime validateSelector:@selector(abc) withClass:[self class]],
                                     NSException,
                                     @"AlchemicSelectorNotFound");
#pragma clang diagnostic pop
}

-(void) testVariableForInjectionPoint {
    Ivar var = [ALCRuntime aClass:[self class] variableForInjectionpoint:@"aStringVariable"];
    XCTAssertNotNil(var);
}

@end
