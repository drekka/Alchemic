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
@property(nonatomic, strong, nonnull) NSString *aStringProperty;
@property(nonatomic, strong, nonnull) NSString *aFunnyStringProperty;
@end

@implementation ALCRuntimeTests {
    NSString *_aStringVariable;
}
@synthesize aFunnyStringProperty = __myFunnyImplVariableName;

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
    XCTAssertEqualObjects(@"_alchemic_testAlchemicSelector", NSStringFromSelector(alcSel));
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

-(void) testVariableForInjectionPointExactMatch {
    Ivar var = [ALCRuntime aClass:[self class] variableForInjectionPoint:@"_aStringVariable"];
    Ivar expected = class_getInstanceVariable([self class], "_aStringVariable");
    XCTAssertEqual(expected, var);
}

-(void) testVariableForInjectionPointWithoutUnderscorePrefix {
    Ivar var = [ALCRuntime aClass:[self class] variableForInjectionPoint:@"aStringVariable"];
    Ivar expected = class_getInstanceVariable([self class], "_aStringVariable");
    XCTAssertEqual(expected, var);
}

-(void) testVariableForInjectionPointProperty {
    Ivar var = [ALCRuntime aClass:[self class] variableForInjectionPoint:@"aStringProperty"];
    Ivar expected = class_getInstanceVariable([self class], "_aStringProperty");
    XCTAssertEqual(expected, var);
}

-(void) testVariableForInjectionPointPrivatePropertyVariable {
    Ivar var = [ALCRuntime aClass:[self class] variableForInjectionPoint:@"_aStringProperty"];
    Ivar expected = class_getInstanceVariable([self class], "_aStringProperty");
    XCTAssertEqual(expected, var);
}

-(void) testVariableForInjectionPointPropertyWithDifferentVariableName {
    Ivar var = [ALCRuntime aClass:[self class] variableForInjectionPoint:@"aFunnyStringProperty"];
    Ivar expected = class_getInstanceVariable([self class], "__myFunnyImplVariableName");
    XCTAssertEqual(expected, var);
}

@end
