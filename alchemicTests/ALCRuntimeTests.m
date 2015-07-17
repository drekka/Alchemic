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
#import <StoryTeller/StoryTeller.h>

#import "ALCRuntime.h"

@interface ALCRuntimeTests : XCTestCase
@property(nonatomic, strong, nonnull) NSString *aStringProperty;
@property(nonatomic, strong, nonnull) NSString *aFunnyStringProperty;
@property(nonatomic, strong, nonnull) id aIdProperty;
@property(nonatomic, assign) int aIntProperty;
@property(nonatomic, strong, nonnull) id<NSCopying> aProtocolProperty;
@property(nonatomic, strong, nonnull) NSString<NSFastEnumeration> *aClassProtocolProperty;
@end

@implementation ALCRuntimeTests {
    NSString *_aStringVariable;
}
@synthesize aFunnyStringProperty = __myFunnyImplVariableName;

#pragma mark - Runtime exploration tests

-(void) testNSObjectProtocolImplements {

    Class stringClass = [NSString class];
    Protocol *nsObjectP = @protocol(NSObject);
    Protocol *nsFastEnumerationP = @protocol(NSFastEnumeration);

    // Runtime functions do not handle hierarchy testing and nsobject is on a parent class.
    // So use NSObject conformsToProtocol: instead.
    BOOL implements = class_conformsToProtocol(stringClass, nsObjectP);
    XCTAssertFalse(implements);

    implements = [stringClass conformsToProtocol:nsObjectP];
    XCTAssertTrue(implements);

    implements = [stringClass conformsToProtocol:nsFastEnumerationP];
    XCTAssertFalse(implements);

}

-(void) testNSObjectClassIsKindOfClass {

    Class stringClass = [NSString class];
    Class mutableStringClass = [NSMutableString class];

    BOOL implements = [stringClass isSubclassOfClass:mutableStringClass];
    XCTAssertFalse(implements);

    implements = [mutableStringClass isSubclassOfClass:stringClass];
    XCTAssertTrue(implements);

    implements = [stringClass isSubclassOfClass:stringClass];
    XCTAssertTrue(implements);

}

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
    XCTAssertEqual(3u, [protocols count]);
    XCTAssertTrue([protocols containsObject:@protocol(NSCopying)]);
    XCTAssertTrue([protocols containsObject:@protocol(NSMutableCopying)]);
    XCTAssertTrue([protocols containsObject:@protocol(NSSecureCoding)]);
    // Not applying the NSObject protocol as every object would have it.
    //XCTAssertTrue([protocols containsObject:@protocol(NSObject)]);
}

-(void) testIVarClassNSString {
    Ivar var = [ALCRuntime aClass:[self class] variableForInjectionPoint:@"aStringProperty"];
    Class iVarClass = [ALCRuntime iVarClass:var];
    XCTAssertEqual([NSString class], iVarClass);
}

-(void) testIVarClassId {
    Ivar var = [ALCRuntime aClass:[self class] variableForInjectionPoint:@"aIdProperty"];
    Class iVarClass = [ALCRuntime iVarClass:var];
    XCTAssertEqual([NSObject class], iVarClass);
}

-(void) testIVarClassProtocol {
    Ivar var = [ALCRuntime aClass:[self class] variableForInjectionPoint:@"aProtocolProperty"];
    Class iVarClass = [ALCRuntime iVarClass:var];
    XCTAssertEqual([NSObject class], iVarClass);
}

-(void) testIVarClassNSStringProtocol {
    Ivar var = [ALCRuntime aClass:[self class] variableForInjectionPoint:@"aClassProtocolProperty"];
    Class iVarClass = [ALCRuntime iVarClass:var];
    XCTAssertEqual([NSString class], iVarClass);
}

-(void) testIVarClassInt {
    Ivar var = [ALCRuntime aClass:[self class] variableForInjectionPoint:@"aIntProperty"];
    Class iVarClass = [ALCRuntime iVarClass:var];
    XCTAssertNil(iVarClass);
}

-(void) testIVarNotFoundException {
    XCTAssertThrowsSpecificNamed([ALCRuntime aClass:[self class] variableForInjectionPoint:@"xxxx"], NSException, @"AlchemicInjectionNotFound");
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

#pragma mark - Qualifiers

-(void) testQualifiersForVariable {
    STStartLogging(ALCHEMIC_LOG);
    Ivar var = [ALCRuntime aClass:[self class] variableForInjectionPoint:@"_aStringProperty"];
    NSSet<id<ALCModelSearchExpression>> *expressions = [ALCRuntime searchExpressionsForVariable:var];
    XCTAssertEqual(1u, [expressions count]);
    XCTAssertTrue([expressions containsObject:[ALCWithClass withClass:[NSString class]]]);
}

@end
