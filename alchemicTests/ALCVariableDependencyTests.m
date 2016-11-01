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
    int aIvar;
    id aObj;
    ALCVariableDependency *_scalarDependency;
    ALCVariableDependency *_objectDependency;
}

-(void)setUp {
    Ivar scalarIvar = class_getInstanceVariable([self class], "aIvar");
    ALCType *scalarType = [ALCType typeWithEncoding:"i"];
    id<ALCValueSource> scalarValue = AcInt(5);
    _scalarDependency = [ALCVariableDependency variableDependencyWithType:scalarType
                                                        valueSource:scalarValue
                                                           intoIvar:scalarIvar
                                                           withName:@"abc"];

    Ivar objIvar = class_getInstanceVariable([self class], "aObj");
    ALCType *objType = [ALCType typeWithClass:[NSObject class]];
    id<ALCValueSource> objValue = AcString(@"xyz");
    _objectDependency = [ALCVariableDependency variableDependencyWithType:objType
                                                        valueSource:objValue
                                                           intoIvar:objIvar
                                                           withName:@"def"];
}

-(void) testFactoryMethod {
    XCTAssertNotNil(_scalarDependency);
    XCTAssertEqualObjects(@"abc", _scalarDependency.name);
}

#pragma mark - Configuring

-(void) testConfigureWithOptionsNillable {
    [_objectDependency configureWithOptions:@[AcNillable]];
}

-(void) testConfigureAScalarWithOptionsNillableThrows {
    XCTAssertThrowsSpecific([_scalarDependency configureWithOptions:@[AcNillable]], AlchemicIllegalArgumentException);
}

-(void) testConfigureWithOptionsUnknownOption {
    XCTAssertThrowsSpecific(([_scalarDependency configureWithOptions:@[@"XXX"]]), AlchemicIllegalArgumentException);
}

#pragma mark - Naming

-(void) testStackName {
    XCTAssertEqualObjects(@"abc", _scalarDependency.stackName);
}

-(void) testResolvingDescription {
    XCTAssertEqualObjects(@"Variable abc", _scalarDependency.resolvingDescription);
}

#pragma mark - Injecting

-(void) testInjecting {
    [_scalarDependency injectObject:self];
    XCTAssertEqual(5, aIvar);
}

    -(void) testInjectionFailure {

        Ivar objIvar = class_getInstanceVariable([self class], "aObj");
        ALCType *objType = [ALCType typeWithClass:[NSObject class]];
        id<ALCValueSource> scalarValue = AcInt(5);

        ALCVariableDependency *dep = [ALCVariableDependency variableDependencyWithType:objType
                                              valueSource:scalarValue
                                                 intoIvar:objIvar
                                                 withName:@"abc"];
        XCTAssertThrowsSpecific([dep injectObject:self], AlchemicInjectionException);
    }

@end
