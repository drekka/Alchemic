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

#pragma mark - Querying

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

-(void) testValidateSelectorValid {
    [ALCRuntime aClass:[self class] validateSelector:@selector(testValidateSelectorValid)];
}

-(void) testValidateSelectorInValid {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wundeclared-selector"
    XCTAssertThrowsSpecificNamed([ALCRuntime  aClass:[self class] validateSelector:@selector(abc)],
                                 NSException,
                                 @"AlchemicSelectorNotFound");
#pragma clang diagnostic pop
}

-(void) testClassVariableForInjectionPointExactMatch {
    Ivar var = [ALCRuntime aClass:[self class] variableForInjectionPoint:@"_aStringVariable"];
    Ivar expected = class_getInstanceVariable([self class], "_aStringVariable");
    XCTAssertEqual(expected, var);
}

-(void) testClassVariableForInjectionPointWithoutUnderscorePrefix {
    Ivar var = [ALCRuntime aClass:[self class] variableForInjectionPoint:@"aStringVariable"];
    Ivar expected = class_getInstanceVariable([self class], "_aStringVariable");
    XCTAssertEqual(expected, var);
}

-(void) testClassVariableForInjectionPointProperty {
    Ivar var = [ALCRuntime aClass:[self class] variableForInjectionPoint:@"aStringProperty"];
    Ivar expected = class_getInstanceVariable([self class], "_aStringProperty");
    XCTAssertEqual(expected, var);
}

-(void) testClassVariableForInjectionPointPrivatePropertyVariable {
    Ivar var = [ALCRuntime aClass:[self class] variableForInjectionPoint:@"_aStringProperty"];
    Ivar expected = class_getInstanceVariable([self class], "_aStringProperty");
    XCTAssertEqual(expected, var);
}

-(void) testClassVariableForInjectionPointPropertyWithDifferentVariableName {
    Ivar var = [ALCRuntime aClass:[self class] variableForInjectionPoint:@"aFunnyStringProperty"];
    Ivar expected = class_getInstanceVariable([self class], "__myFunnyImplVariableName");
    XCTAssertEqual(expected, var);
}

-(void) testClassProtocols {
    NSSet<Protocol *> *protocols = [ALCRuntime aClassProtocols:[NSString class]];
    XCTAssertEqual(4u, [protocols count]);
    XCTAssertTrue([protocols containsObject:@protocol(NSCopying)]);
    XCTAssertTrue([protocols containsObject:@protocol(NSMutableCopying)]);
    XCTAssertTrue([protocols containsObject:@protocol(NSSecureCoding)]);
    XCTAssertTrue([protocols containsObject:@protocol(NSObject)]);
}

#pragma mark - General

-(void) testAlchemicSelector {
    SEL alcSel = [ALCRuntime alchemicSelectorForSelector:@selector(testAlchemicSelector)];
    XCTAssertEqualObjects(@"_alchemic_testAlchemicSelector", NSStringFromSelector(alcSel));
}

-(void) testInjectVariableValue {
    Ivar var = [ALCRuntime aClass:[self class] variableForInjectionPoint:@"_aStringProperty"];
    [ALCRuntime object:self injectVariable:var withValue:@"abc"];
    XCTAssertEqualObjects(@"abc", self.aStringProperty);
}

@end
