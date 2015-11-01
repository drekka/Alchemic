//
//  ALCObjectBuilderTests.m
//  alchemic
//
//  Created by Derek Clarkson on 26/08/2015.
//  Copyright © 2015 Derek Clarkson. All rights reserved.
//

@import XCTest;
#import "ALCTestCase.h"
#import <OCMock/OCMock.h>
#import <Alchemic/Alchemic.h>
#import <StoryTeller/StoryTeller.h>

#import "ALCBuilder.h"

#import "ALCBuilderStorageSingleton.h"
#import "ALCBuilderStorageFactory.h"
#import "ALCBuilderStorageExternal.h"

#import "SimpleObject.h"
#import "ALCMacroProcessor.h"

#import "ALCClassBuilderType.h"
#import "ALCMethodBuilderType.h"
#import "ALCInitializerBuilderType.h"

@interface ALCBuilder (_internal)
-(void) resolveWithDependencyStack:(NSMutableArray<id<ALCResolvable>> *) dependencyStack;
@end

@interface ALCBuilderTests : ALCTestCase
@end

@implementation ALCBuilderTests {
    ALCBuilder *_builder;
}

-(void)setUp {
    _builder = [self simpleBuilderForClass:[SimpleObject class]];
    _builder.registered = YES;
}

#pragma mark - Builder types

-(void) testIsClassBuilder {
    ALCClassBuilderType *classType = [[ALCClassBuilderType alloc] initWithType:[SimpleObject class]];
    ALCBuilder *builder = [[ALCBuilder alloc] initWithBuilderType:classType];
    XCTAssertTrue(builder.isClassBuilder);
}

-(void) testBuilderTypeMethod {
    id mockClassBuilder = OCMClassMock([ALCBuilder class]);
    ALCMethodBuilderType *methodType = [[ALCMethodBuilderType alloc] initWithType:[SimpleObject class]
                                                               parentClassBuilder:mockClassBuilder
                                                                         selector:@selector(init)];
    ALCBuilder *builder = [[ALCBuilder alloc] initWithBuilderType:methodType];
    XCTAssertFalse(builder.isClassBuilder);
}

#pragma mark - Configure

-(void) testConfigureDefaultSingletonStorage {
    [_builder configure];
    Ivar storageVar = class_getInstanceVariable([ALCBuilder class], "_builderStorage");
    id storage = object_getIvar(_builder, storageVar);
    XCTAssertTrue([storage isKindOfClass:[ALCBuilderStorageSingleton class]]);
}

-(void) testConfigureFactoryStorage {
    [_builder.macroProcessor addMacro:AcFactory];
    [_builder configure];
    Ivar storageVar = class_getInstanceVariable([ALCBuilder class], "_builderStorage");
    id storage = object_getIvar(_builder, storageVar);
    XCTAssertTrue([storage isKindOfClass:[ALCBuilderStorageFactory class]]);
}

-(void) testConfigureExternalStorage {
    [_builder.macroProcessor addMacro:AcExternal];
    [_builder configure];
    Ivar storageVar = class_getInstanceVariable([ALCBuilder class], "_builderStorage");
    id storage = object_getIvar(_builder, storageVar);
    XCTAssertTrue([storage isKindOfClass:[ALCBuilderStorageExternal class]]);
}

-(void) testConfigureExternalStorageWhenNotRegistered {
    _builder.registered = NO;
    [_builder configure];
    Ivar storageVar = class_getInstanceVariable([ALCBuilder class], "_builderStorage");
    id storage = object_getIvar(_builder, storageVar);
    XCTAssertTrue([storage isKindOfClass:[ALCBuilderStorageExternal class]]);
}

-(void) testConfigureDefaultName {
    [_builder configure];
    XCTAssertEqualObjects(@"SimpleObject", _builder.name);
}

-(void) testConfigureWithNameSetsNewName {
    [_builder.macroProcessor addMacro:AcWithName(@"abc")];
    [_builder configure];
    XCTAssertEqualObjects(@"abc", _builder.name);
}

#pragma mark - Resolving

-(void) testResolveDefault {
    [self configureAndResolveBuilder:_builder]; // Doesn't throw.
}

-(void) testResolveWhenCircularDependency {
    NSMutableArray *stack = [NSMutableArray arrayWithObject:_builder];
    XCTAssertThrowsSpecificNamed([_builder resolveWithDependencyStack:stack], NSException, @"AlchemicCircularDependency");
}

#pragma mark - Ready

-(void) testBuilderReadyWhenSingletonStorage {
    [_builder.macroProcessor addMacro:AcWithName(@"abc")];
    [self configureAndResolveBuilder:_builder];
    XCTAssertTrue(_builder.ready);
}

-(void) testBuilderReadyWhenFactoryStorage {
    [_builder.macroProcessor addMacro:AcFactory];
    [self configureAndResolveBuilder:_builder];
    XCTAssertTrue(_builder.ready);
}

-(void) testBuilderReadyWhenExternalStorageWithValue {
    [_builder.macroProcessor addMacro:AcExternal];
    [self configureAndResolveBuilder:_builder];
    _builder.value = [[SimpleObject alloc] init];
    XCTAssertTrue(_builder.ready);
}

-(void) testBuilderNotReadyWhenExternalStorageWithoutValue {
    [_builder.macroProcessor addMacro:AcExternal];
    [self configureAndResolveBuilder:_builder];
    XCTAssertFalse(_builder.ready);
}

#pragma mark - Value

-(void) testValue {
    [self configureAndResolveBuilder:_builder];

    SimpleObject *so = _builder.value;
    XCTAssertNotNil(so);
}

-(void) testValueCachesValue {
    [self configureAndResolveBuilder:_builder];

    SimpleObject *so1 = _builder.value;
    SimpleObject *so2 = _builder.value;
    XCTAssertEqual(so1, so2);
}

-(void) testValueThrowsWhenNotReady {
    [_builder configure];
    XCTAssertThrowsSpecificNamed(_builder.value, NSException, @"AlchemicBuilderNotAvailable");
}


-(void) testSetValue {
    [self configureAndResolveBuilder:_builder];
    _builder.value = @"abc";
    XCTAssertEqualObjects(@"abc", _builder.value);
}

#pragma mark - Description

-(void) testDescriptionForClass {
    STStartLogging(@"LogAll");
    [self configureAndResolveBuilder:_builder];
    XCTAssertEqualObjects(@"* builder for type SimpleObject, name 'SimpleObject', singleton, value present, class builder", [_builder description]);
}

-(void) testDescriptionForClassWhenInstantiated {
    [self configureAndResolveBuilder:_builder];
    [_builder value];
    XCTAssertEqualObjects(@"* builder for type SimpleObject, name 'SimpleObject', singleton, value present, class builder", [_builder description]);

}

-(void) testDescriptionForClassFactory {
    [_builder.macroProcessor addMacro:AcFactory];
    [self configureAndResolveBuilder:_builder];
    XCTAssertEqualObjects(@"  builder for type SimpleObject, name 'SimpleObject', factory, class builder", [_builder description]);
}

-(void) testDescriptionForClassExternal {
    [_builder.macroProcessor addMacro:AcExternal];
    [_builder configure];
    XCTAssertEqualObjects(@"  builder for type SimpleObject, name 'SimpleObject', external, class builder", [_builder description]);
}

@end
