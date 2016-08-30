//
//  ALCVariableDependencyTests.m
//  alchemic
//
//  Created by Derek Clarkson on 21/07/2016.
//  Copyright © 2016 Derek Clarkson. All rights reserved.
//

@import XCTest;
@import Alchemic;
@import Alchemic.Private;
@import ObjectiveC;
@import OCMock;

@interface ALCVariableDependencyTests : XCTestCase

@end

@implementation ALCVariableDependencyTests {
    id aIvar;
    ALCVariableDependency *_dependency;
    Ivar _ivar;
}

-(void)setUp {
    _ivar = class_getInstanceVariable([self class], "aIvar");
    ALCType *type = [ALCType typeWithEncoding:"i"];
    id<ALCValueSource> source = [ALCConstantValueSource valueSourceWithInt:5];
    _dependency = [ALCVariableDependency variableDependencyWithType:type
                                                        valueSource:source
                                                           intoIvar:_ivar
                                                               name:@"abc"];
}

-(void) testFactoryMethod {
    XCTAssertNotNil(_dependency);
    XCTAssertEqualObjects(@"abc", _dependency.name);
}

#pragma mark - Configuring

-(void) testConfigureWithOptionsNillable {
    [_dependency configureWithOptions:@[AcNillable]];
}

-(void) testConfigureWithOptionsTransient {
    [_dependency configureWithOptions:@[AcTransient]];
    XCTAssertTrue(_dependency.transient);
}

-(void) testConfigureWithOptionsUnknownOption {
    XCTAssertThrowsSpecific(([_dependency configureWithOptions:@[@"XXX"]]), AlchemicIllegalArgumentException);
}

#pragma mark - Naming

-(void) testStackName {
    XCTAssertEqualObjects(@"abc", _dependency.stackName);
}

-(void) testResolvingDescription {
    XCTAssertEqualObjects(@"Variable abc", _dependency.resolvingDescription);
}

#pragma mark - Injecting

-(void) testInjecting {
    [_dependency injectObject:@"abc"];
}

@end
