//
//  SingletonToSingleton.m
//  Alchemic
//
//  Created by Derek Clarkson on 30/01/2016.
//  Copyright © 2016 Derek Clarkson. All rights reserved.
//

@import XCTest;

#import "ALCContext.h"
#import "ALCContextImpl.h"
#import "ALCObjectFactory.h"
#import "ALCClassObjectFactory.h"
#import "ALCModelSearchCriteria.h"
#import "ALCModelDependency.h"
#import "ALCDependency.h"

@interface TestDepClass:NSObject
@end

@implementation TestDepClass
@end

@interface TestClass1:NSObject
@property (nonatomic, strong) TestDepClass *dep;
@end

@implementation TestClass1
@end

@interface TestClass2:NSObject
@property (nonatomic, strong) NSArray<TestDepClass *> *deps;
@end

@implementation TestClass2
@end

@interface BasicDependencies : XCTestCase
@end

@implementation BasicDependencies {
    id<ALCContext> context;
}

-(void) setUp {
    context = [[ALCContextImpl alloc] init];
}

-(void) testSimpleDependency {

    ALCClassObjectFactory *valueFactory = [context registerClass:[TestClass1 class]];
    [context registerClass:[TestDepClass class]];

    ALCModelSearchCriteria *criteria = [ALCModelSearchCriteria searchCriteriaForClass:[TestDepClass class]];
    id<ALCDependency> modelDependency = [[ALCModelDependency alloc] initWithCriteria:criteria];
    [valueFactory registerDependency:modelDependency forVariable:@"dep"];

    [context start];

    TestClass1 *singleton = valueFactory.object;
    XCTAssertNotNil(singleton);
    XCTAssertNotNil(singleton.dep);
    XCTAssertTrue([singleton.dep isKindOfClass:[TestDepClass class]]);
}

-(void) testSimpleArrayDependency {

    ALCClassObjectFactory *valueFactory = [context registerClass:[TestClass2 class]];
    id<ALCObjectFactory> depFactory = [context registerClass:[TestDepClass class]];
    [context objectFactory:depFactory changedName:@"TestDepClass" newName:@"dep1"];
    depFactory = [context registerClass:[TestDepClass class]];
    [context objectFactory:depFactory changedName:@"TestDepClass" newName:@"dep2"];

    ALCModelSearchCriteria *criteria = [ALCModelSearchCriteria searchCriteriaForClass:[TestDepClass class]];
    id<ALCDependency> modelDependency = [[ALCModelDependency alloc] initWithCriteria:criteria];
    [valueFactory registerDependency:modelDependency forVariable:@"deps"];

    [context start];

    TestClass2 *singleton = valueFactory.object;
    XCTAssertNotNil(singleton);
    XCTAssertNotNil(singleton.deps);
    XCTAssertTrue([singleton.deps isKindOfClass:[NSArray class]]);
    XCTAssertEqual(2u, [singleton.deps count]);
    XCTAssertNotEqual(singleton.deps[0], singleton.deps[1]);
}

-(void) testSimpleDependencyUsingName {

    ALCClassObjectFactory *valueFactory = [context registerClass:[TestClass2 class]];
    id<ALCObjectFactory> depFactory = [context registerClass:[TestDepClass class]];
    [context objectFactory:depFactory changedName:@"TestDepClass" newName:@"dep1"];
    depFactory = [context registerClass:[TestDepClass class]];
    [context objectFactory:depFactory changedName:@"TestDepClass" newName:@"dep2"];

    ALCModelSearchCriteria *criteria = [ALCModelSearchCriteria searchCriteriaForName:@"dep2"];
    id<ALCDependency> modelDependency = [[ALCModelDependency alloc] initWithCriteria:criteria];
    [valueFactory registerDependency:modelDependency forVariable:@"deps"];

    [context start];

    TestClass2 *singleton = valueFactory.object;
    XCTAssertNotNil(singleton);
    XCTAssertNotNil(singleton.deps);
    XCTAssertTrue([singleton.deps isKindOfClass:[NSArray class]]);
    XCTAssertEqual(1u, [singleton.deps count]);
}

-(void) testSimpleDependencyUsingClassAndName {

    ALCClassObjectFactory *valueFactory = [context registerClass:[TestClass1 class]];
    id<ALCObjectFactory> depFactory = [context registerClass:[TestDepClass class]];
    [context objectFactory:depFactory changedName:@"TestDepClass" newName:@"dep1"];
    depFactory = [context registerClass:[TestDepClass class]];
    [context objectFactory:depFactory changedName:@"TestDepClass" newName:@"dep2"];

    ALCModelSearchCriteria *classCriteria = [ALCModelSearchCriteria searchCriteriaForClass:[TestDepClass class]];
    ALCModelSearchCriteria *nameCriteria = [ALCModelSearchCriteria searchCriteriaForName:@"dep2"];
    classCriteria.nextSearchCriteria = nameCriteria;

    id<ALCDependency> modelDependency = [[ALCModelDependency alloc] initWithCriteria:classCriteria];
    [valueFactory registerDependency:modelDependency forVariable:@"dep"];

    [context start];

    TestClass1 *singleton = valueFactory.object;
    XCTAssertNotNil(singleton);
    XCTAssertNotNil(singleton.dep);
}

@end

