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

@interface NSArray_AlchemicTests : XCTestCase

@end

@implementation NSArray_AlchemicTests

-(void) testMethodArgumentsWithUnknownArgumentHandlerWithMethodArgument {

    ALCMethodArgumentDependency *argument = AcArg(NSString, AcString(@"abc"));
    NSArray<ALCMethodArgumentDependency *> *args = @[argument];

    __block BOOL handlerCalled = NO;
    NSArray<id<ALCDependency>> *methodArgs = [args methodArgumentsWithUnknownArgumentHandler:^(id passedArgument){
        handlerCalled = YES;
    }];

    XCTAssertFalse(handlerCalled);
    XCTAssertEqual(1u, methodArgs.count);
    ALCMethodArgumentDependency *returnedArg = methodArgs[0];
    XCTAssertEqual(0, returnedArg.index);
    XCTAssertEqual(argument, returnedArg);
}

-(void) testMethodArgumentsWithUnknownArgumentHandlerWithSearchCriteria {

    NSArray *args = @[AcClass(NSString)];

    __block BOOL handlerCalled = NO;
    NSArray<id<ALCDependency>> *methodArgs = [args methodArgumentsWithUnknownArgumentHandler:^(id passedArgument){
        handlerCalled = YES;
    }];

    XCTAssertFalse(handlerCalled);
    XCTAssertEqual(1u, methodArgs.count);
    ALCMethodArgumentDependency *returnedArg = methodArgs[0];
    XCTAssertEqual(0, returnedArg.index);

    id<ALCInjector> injector = returnedArg.injector;
    XCTAssertNotNil(injector);
}


-(void) testMethodArgumentsWithUnknownArgumentHandlerWithUnknownArgumentCallsHandler {

    NSArray *args = @[@"abc"];

    __block BOOL handlerCalled = NO;
    __unused NSArray<id<ALCDependency>> *methodArgs = [args methodArgumentsWithUnknownArgumentHandler:^(id passedArgument){
        handlerCalled = YES;
        XCTAssertEqualObjects(@"abc", passedArgument);
    }];

    XCTAssertTrue(handlerCalled);
}


@end
