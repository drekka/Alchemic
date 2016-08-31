//
//  NSArray+AlchemicTests.m
//  Alchemic
//
//  Created by Derek Clarkson on 4/07/2016.
//  Copyright © 2016 Derek Clarkson. All rights reserved.
//

@import XCTest;
@import Alchemic;
@import Alchemic.Private;
@import OCMock;

@interface NSArray_AlchemicTests : XCTestCase

@end

@implementation NSArray_AlchemicTests

#pragma mark - Method arguments

-(void) testMethodArgumentsWithUnknownArgumentHandlerWithMethodArgument {
    ALCMethodArgumentDependency *argument = AcArg(NSString, AcString(@"abc"));
    NSArray *args = @[argument];
    [self runMethodArgumentsTestWithValidArguments:args types:@[[ALCType typeWithClass:[NSString class]]]];
}

-(void) testMethodArgumentsWithUnknownArgumentHandlerWithSearchCriteria {
    NSArray *args = @[AcClass(NSString)];
    [self runMethodArgumentsTestWithValidArguments:args types:@[[ALCType typeWithClass:[NSString class]]]];
}

-(void) testMethodArgumentsWithUnknownArgumentHandlerWithConstant {
    NSArray *args = @[AcInt(5)];
    [self runMethodArgumentsTestWithValidArguments:args types:@[[ALCType typeWithEncoding:"i"]]];
}

-(void) testMethodArgumentsWithUnknownArgumentHandlerWithUnknownArgumentCallsHandler {
    
    NSArray *args = @[@"abc"];
    
    __block BOOL handlerCalled = NO;
    __unused NSArray<id<ALCDependency>> *methodArgs = [args methodArgumentsWithExpectedTypes:@[[ALCType typeWithClass:[NSString class]]]
                                                                             unknownArgument:^(id passedArgument){
                                                                                 handlerCalled = YES;
                                                                                 XCTAssertEqualObjects(@"abc", passedArgument);
                                                                             }];
    
    XCTAssertTrue(handlerCalled);
}

-(void) testMethodArgumentsWithUnknownArgumentHandlerWithNoArgs {
    
    NSArray *args = @[];
    
    NSArray<id<ALCDependency>> *methodArgs = [args methodArgumentsWithExpectedTypes:@[]
                                                                    unknownArgument:^(id passedArgument){
                                                                        XCTFail(@"Nothing to call block with");
                                                                    }];
    
    XCTAssertNotNil(methodArgs);
    XCTAssertEqual(0u, methodArgs.count);
}

#pragma mark - Model search criteria

-(void) testModelSerchCriteriaWithNoCriteria {
    ALCModelSearchCriteria *searchCriteria = [@[] modelSearchCriteriaWithDefaultClass:NULL
                                                               unknownArgumentHandler:^(id argument) {
                                                                   XCTFail(@"Argument not found");
                                                               }];
    XCTAssertNil(searchCriteria);
}

-(void) testModelSerchCriteriaWithClass {
    [self runModelSearchCriteria:@[AcClass(NSObject)] expectedDescription:@"class NSObject"];
}

-(void) testModelSerchCriteriaWithClassAndProtocol {
    [self runModelSearchCriteria:@[AcClass(NSString), AcProtocol(NSCopying)] expectedDescription:@"class NSString and protocol NSCopying"];
}

#pragma mark - resolving

-(void) testResolveWithStackModel {
    
    id modelMock = OCMProtocolMock(@protocol(ALCModel));
    NSMutableArray *stack = [[NSMutableArray alloc] init];
    
    id argMock1 = OCMProtocolMock(@protocol(ALCDependency));
    id argMock2 = OCMProtocolMock(@protocol(ALCDependency));
    NSArray *args = @[argMock1, argMock2];
    
    OCMExpect([argMock1 resolveWithStack:stack model:modelMock]);
    OCMExpect([argMock2 resolveWithStack:stack model:modelMock]);
    
    [args resolveWithStack:stack model:modelMock];
    
    XCTAssertEqual(0u, stack.count);
    
    OCMVerifyAll(argMock1);
    OCMVerifyAll(argMock2);
}

#pragma mark - Dependencies ready

-(void) testDependenciesReadyAlreadyChecking {
    
    BOOL checking = YES;
    
    id depMock1 = OCMProtocolMock(@protocol(ALCDependency));
    id depMock2 = OCMProtocolMock(@protocol(ALCDependency));
    NSArray *deps = @[depMock1, depMock2];
    
    XCTAssertTrue([deps dependenciesReadyWithCheckingFlag:&checking]);
    XCTAssertTrue(checking);
    
}

-(void) testDependenciesReadyAllReady {
    
    BOOL checking = NO;
    
    id depMock1 = OCMProtocolMock(@protocol(ALCDependency));
    id depMock2 = OCMProtocolMock(@protocol(ALCDependency));
    NSArray *deps = @[depMock1, depMock2];
    
    OCMStub([depMock1 isReady]).andReturn(YES);
    OCMStub([depMock2 isReady]).andReturn(YES);
    
    XCTAssertTrue([deps dependenciesReadyWithCheckingFlag:&checking]);
    XCTAssertFalse(checking);
    
}

-(void) testDependenciesReadyAllNotReady {
    
    BOOL checking = NO;
    
    id depMock1 = OCMProtocolMock(@protocol(ALCDependency));
    id depMock2 = OCMProtocolMock(@protocol(ALCDependency));
    NSArray *deps = @[depMock1, depMock2];
    
    OCMStub([depMock1 isReady]).andReturn(NO);
    OCMStub([depMock2 isReady]).andReturn(NO);
    
    XCTAssertFalse([deps dependenciesReadyWithCheckingFlag:&checking]);
    XCTAssertFalse(checking);
    
}

#pragma mark - Internal

-(void) runMethodArgumentsTestWithValidArguments:(NSArray *) args
                                           types:(NSArray<ALCType *> *) types {
    
    __block BOOL handlerCalled = NO;
    NSArray<id<ALCDependency>> *methodArgs = [args methodArgumentsWithExpectedTypes:types
                                                                    unknownArgument:^(id passedArgument) {
                                                                        handlerCalled = YES;
                                                                    }];
    
    XCTAssertFalse(handlerCalled);
    XCTAssertEqual(1u, methodArgs.count);
    ALCMethodArgumentDependency *returnedArg = (ALCMethodArgumentDependency *) methodArgs[0];
    XCTAssertEqual(0u, returnedArg.index);
    
}

-(void) runModelSearchCriteria:(NSArray *) criteria expectedDescription:(NSString *) description {
    ALCModelSearchCriteria *searchCriteria = [criteria modelSearchCriteriaWithDefaultClass:NULL
                                                                    unknownArgumentHandler:^(id argument) {
                                                                        XCTFail(@"Argument not found");
                                                                    }];
    XCTAssertNotNil(searchCriteria);
    XCTAssertEqualObjects(description, searchCriteria.description);
}


@end
