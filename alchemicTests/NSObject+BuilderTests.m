//
//  NSObject+BuilderTests.m
//  alchemic
//
//  Created by Derek Clarkson on 26/08/2015.
//  Copyright © 2015 Derek Clarkson. All rights reserved.
//

@import XCTest;
@import ObjectiveC;
#import <OCMock/OCMock.h>
#import "NSObject+Builder.h"
#import "ALCRuntime.h"
#import "ALCVariableDependency.h"
#import "ALCConstantValueSource.h"
#import "AlchemicAware.h"

@interface NSObject_BuilderTests : XCTestCase<AlchemicAware>
@property(nonatomic, strong, nonnull) NSString *aStringProperty;
@end

@implementation NSObject_BuilderTests {
    NSString *_stringVar;
    BOOL _dependenciesInjected;
}

-(void) testInvokeSelector {
    id result = [self invokeSelector:@selector(method) arguments:@[]];
    XCTAssertEqualObjects(@"abc", result);
}

-(void) testInvokeSelectorWithArg {
    id result = [self invokeSelector:@selector(methodWithArg:) arguments:@[@"def"]];
    XCTAssertEqualObjects(@"def", result);
}

-(void) testInvokeSelectorWithMissingArg {
    id result = [self invokeSelector:@selector(methodWithArg:) arguments:@[]];
    XCTAssertNil(result);
}

-(void) testInjectWithDependencies {

    _dependenciesInjected = NO;
    Ivar stringVar = class_getInstanceVariable([self class], "_stringVar");
    ALCConstantValueSource *valueSource = [[ALCConstantValueSource alloc] initWithType:[NSString class] value:@"abc" whenAvailable:NULL];
    ALCVariableDependency *dependency = [[ALCVariableDependency alloc] initWithVariable:stringVar valueSource:valueSource];
    [dependency resolveWithPostProcessors:[NSSet set] dependencyStack:[[NSMutableArray alloc] init]];

    [self injectWithDependencies:@[dependency]];

    XCTAssertEqualObjects(@"abc", _stringVar);
    XCTAssertTrue(_dependenciesInjected);
}

-(void) alchemicDidInjectDependencies {
    _dependenciesInjected = YES;
}

-(void) testInjectVariableValue {
    Ivar var = [ALCRuntime aClass:[self class] variableForInjectionPoint:@"_aStringProperty"];
    [self injectVariable:var withValue:@"abc"];
    XCTAssertEqualObjects(@"abc", self.aStringProperty);
}

#pragma mark - Internal

-(id) method {
    return @"abc";
}

-(id) methodWithArg:(NSString *) arg {
    return arg;
}
@end
