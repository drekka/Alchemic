//
//  ALCAbstractBuilderTests.m
//  Alchemic
//
//  Created by Derek Clarkson on 26/07/2015.
//  Copyright © 2015 Derek Clarkson. All rights reserved.
//

@import XCTest;
#import "ALCAbstractBuilder.h"
#import "ALCMethodMacroProcessor.h"
#import <Alchemic/Alchemic.h>
#import "SimpleObject.h"

@interface FakeBuilder : ALCAbstractBuilder
@property(nonatomic, assign) BOOL resolveDependenciesCalled;
@property(nonatomic, assign) BOOL injectObjectCalled;
@end

@implementation FakeBuilder

-(void) resolveDependenciesWithPostProcessors:(NSSet<id<ALCDependencyPostProcessor>> *)postProcessors {
	self.resolveDependenciesCalled = YES;
}

-(nonnull id) instantiateObject {
	return [[SimpleObject alloc] init];
}

-(void) injectObjectDependencies:(id) object {
	self.injectObjectCalled = YES;
}

@end

@interface ALCAbstractBuilderTests : XCTestCase {
	FakeBuilder *_builder;
}

@end

#pragma mark - Tests

@implementation ALCAbstractBuilderTests

-(void) setUp {
	_builder = [[FakeBuilder alloc] initWithValueClass:[SimpleObject class]];
}

#pragma mark - Creating objects

-(void) testInitWithValueClass {
	XCTAssertEqual([SimpleObject class], _builder.valueClass);
}

-(void) testValueBuildsAndInjects {
	id value = _builder.value;
	XCTAssertNotNil(value);
	XCTAssertEqual([SimpleObject class], [value class]);
	XCTAssertTrue(_builder.injectObjectCalled);
}

-(void) testValueCachesWhenNotAFactory {
	id value1 = _builder.value;
	id value2 = _builder.value;
	XCTAssertEqual(value1, value2);
}

-(void) testValueCreatesNewValueWHenAFactory {
	_builder.factory = YES;
	id value1 = _builder.value;
	id value2 = _builder.value;
	XCTAssertNotEqual(value1, value2);
}

-(void) testInstantiateCreatesObjectButDoesNotWireIt {
	id value = [_builder instantiate];
	XCTAssertNotNil(value);
	XCTAssertEqual([SimpleObject class], [value class]);
	XCTAssertFalse(_builder.injectObjectCalled);
}

#pragma mark - Validations

-(void) testValidateSelector {
	[_builder validateSelector:@selector(description)];
}

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wundeclared-selector"
-(void) testValidateSelectorThrowsWhenNotFound {
	XCTAssertThrowsSpecificNamed([_builder validateSelector:@selector(xxxx)], NSException, @"AlchemicSelectorNotFound");
}
#pragma clang diagnostic pop

-(void) testValidateArgumentsForSelectorWhenNoArgs {
	ALCMethodMacroProcessor *macroProcessor = [[ALCMethodMacroProcessor alloc] init];
	[_builder validateArgumentsForSelector:@selector(description) macroProcessor:macroProcessor];
}

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wselector"
-(void) testValidateArgumentsForSelector {
	ALCMethodMacroProcessor *macroProcessor = [[ALCMethodMacroProcessor alloc] init];
	[macroProcessor addMacro:AcArg(NSString, AcValue(@"abc"))];
	[_builder validateArgumentsForSelector:@selector(aMethodWithAString:) macroProcessor:macroProcessor];
}
#pragma clang diagnostic pop

-(void) testValidateArgumentsForSelectorWithToFewNumberArguments {
	ALCMethodMacroProcessor *macroProcessor = [[ALCMethodMacroProcessor alloc] init];
	XCTAssertThrowsSpecificNamed([_builder validateArgumentsForSelector:@selector(aMethodWithAString:) macroProcessor:macroProcessor], NSException, @"AlchemicIncorrectNumberArguments");
}

-(void) testValidateArgumentsForSelectorWithToManyNumberArguments {
	ALCMethodMacroProcessor *macroProcessor = [[ALCMethodMacroProcessor alloc] init];
	[macroProcessor addMacro:AcArg(NSString, AcValue(@"abc"))];
	[macroProcessor addMacro:AcArg(NSString, AcValue(@"def"))];
	XCTAssertThrowsSpecificNamed([_builder validateArgumentsForSelector:@selector(aMethodWithAString:) macroProcessor:macroProcessor], NSException, @"AlchemicIncorrectNumberArguments");
}

@end
