//
//  ALCBuilderDependencyManagerTests.m
//  alchemic
//
//  Created by Derek Clarkson on 26/08/2015.
//  Copyright © 2015 Derek Clarkson. All rights reserved.
//

@import XCTest;
#import "ALCBuilderDependencyManager.h"
#import <OCMock/OCMock.h>
#import "ALCDependency.h"
#import "ALCConstantValueSource.h"

@interface ALCDependency (_hack)
@property (nonatomic, assign) BOOL available;
@end

@interface ALCBuilderDependencyManagerTests : XCTestCase

@end

@implementation ALCBuilderDependencyManagerTests {
    ALCBuilderDependencyManager *_depManagerWithMocks;
    ALCBuilderDependencyManager *_depManager;
    id _mockDep1;
    id _mockDep2;
    ALCDependency *_dep1;
    ALCDependency *_dep2;
}

-(void) setUp {

    //Mocked setup.
    _mockDep1 = OCMClassMock([ALCDependency class]);
    _mockDep2 = OCMClassMock([ALCDependency class]);

    OCMStub([(ALCDependency *)_mockDep1 value]).andReturn(@"abc");
    OCMStub([(ALCDependency *)_mockDep2 value]).andReturn(@12);

    _depManagerWithMocks = [[ALCBuilderDependencyManager alloc] init];

    [_depManagerWithMocks addDependency:_mockDep1];
    [_depManagerWithMocks addDependency:_mockDep2];

    // Real setup
    ALCConstantValueSource *stringValueSource = [[ALCConstantValueSource alloc] initWithType:[NSString class] value:@"abc"];
    _dep1 = [[ALCDependency alloc] initWithValueSource:stringValueSource];
    ALCConstantValueSource *numberValueSource = [[ALCConstantValueSource alloc] initWithType:[NSString class] value:@12];
    _dep2 = [[ALCDependency alloc] initWithValueSource:numberValueSource];

    _depManager = [[ALCBuilderDependencyManager alloc] init];

    [_depManager addDependency:_dep1];
    [_depManager addDependency:_dep2];
}

-(void) testNumberOfDependencies {
    XCTAssertEqual(2u, [_depManagerWithMocks numberOfDependencies]);
}

-(void) testDependencyValues {
    [_depManager resolveWithPostProcessors:[NSSet set] dependencyStack:[NSMutableArray array]];
    NSArray *values = _depManager.dependencyValues;
    XCTAssertEqualObjects(@"abc", values[0]);
    XCTAssertEqualObjects(@12, values[1]);
}

-(void) testResolveWithPostProcessors {

    NSSet *postProcessors = [NSSet set];
    NSMutableArray *stack = [NSMutableArray array];

    [_depManagerWithMocks resolveWithPostProcessors:postProcessors dependencyStack:stack];

    OCMVerify([_mockDep1 resolveWithPostProcessors:postProcessors dependencyStack:stack]);
    OCMVerify([_mockDep2 resolveWithPostProcessors:postProcessors dependencyStack:stack]);
}

#pragma mark - Available

-(void) testAvailableAfterResolve {

    XCTAssertFalse(_depManager.available);

    [_depManager resolveWithPostProcessors:[NSSet set] dependencyStack:[NSMutableArray array]];
    XCTAssertTrue(_depManager.available);

}

-(void) testAvailableAsDependenciesComeOnline {

    XCTAssertFalse(_depManager.available);

    _dep1.available = YES;
    XCTAssertFalse(_depManager.available);

    _dep2.available = YES;
    XCTAssertTrue(_depManager.available);
    
}


@end
