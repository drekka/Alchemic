//
//  NSObject+AlchemicTests.m
//  Alchemic
//
//  Created by Derek Clarkson on 25/05/2016.
//  Copyright © 2016 Derek Clarkson. All rights reserved.
//

@import XCTest;
@import Alchemic;
@import Alchemic.Private;

@interface NSObject_AlchemicTests : XCTestCase

@end

@implementation NSObject_AlchemicTests

#pragma mark - Invoking selectors

// These instance method invoke tests are effectively being used to test out the internal object:invokeSelector:arguments: method.

-(void) testInstanceInvokeSelectorArgumentsThrowsWhenMethodReturnsIncorrectType {
    XCTAssertThrowsSpecific([@"abc" invokeSelector:@selector(length) arguments:nil], AlchemicIllegalArgumentException);
}

-(void) testInstanceInvokeSelectorArgumentsThrowsWhenClassMethodPassed {
    XCTAssertThrowsSpecific([@"abc" invokeSelector:@selector(availableStringEncodings) arguments:nil], AlchemicMethodNotFoundException);
}

-(void) testInstanceInvokeSelectorArgumentsThrowsWhenMethodHasVoidReturn {
    XCTAssertThrowsSpecific([@"abc" invokeSelector:@selector(drawAtPoint:withAttributes:) arguments:nil], AlchemicIllegalArgumentException);
}

-(void) testInstanceInvokeSelectorArguments {
    NSString *result = [@"abc" invokeSelector:@selector(localizedCapitalizedString) arguments:nil];
    XCTAssertEqualObjects(@"Abc", result);
}

-(void) testInstanceInvokeSelectorArgumentsWithArgs {
    id<ALCDependency> arg = AcArg(NSString, AcString(@"def"));
    NSString *result = [@"abc" invokeSelector:@selector(stringByAppendingString:) arguments:@[arg]];
    XCTAssertEqualObjects(@"abcdef", result);
}

-(void) testClassInvokeSelector {
    NSDate *date = [NSDate invokeSelector:@selector(date) arguments:nil];
    XCTAssertNotNil(date);
}

-(void) testClassInvokeSelectorArgumentsThrowsWhenInstanceMethodPassed {
    XCTAssertThrowsSpecific([NSString invokeSelector:@selector(localizedCapitalizedString) arguments:nil], AlchemicMethodNotFoundException);
}

#pragma mark - Resolving

-(void) testResolveWithResolvingStackIfNotResolvedCallsBlock {

    NSMutableArray *stack = [[NSMutableArray alloc] init];
    __block BOOL resolved = NO;
    __block BOOL blockCalled = NO;
    // Must be an object factory.
    ALCType *type = [ALCType typeWithClass:[NSString class]];
    ALCClassObjectFactory *factory = [[ALCClassObjectFactory alloc] initWithType:type];

    [factory resolveWithStack:stack
                 resolvedFlag:&resolved
                        block:^{
                            XCTAssertTrue([stack containsObject:factory]);
                            XCTAssertTrue(resolved);
                            blockCalled = YES;
                        }];

    XCTAssertTrue(blockCalled);
    XCTAssertEqual(0u, stack.count);
}

-(void) testResolveWithResolvingStackWhenObjectNotInStack {

    NSMutableArray *stack = [[NSMutableArray alloc] init];
    __block BOOL resolved = YES;

    // Must be an object factory.
    ALCType *type = [ALCType typeWithClass:[NSString class]];
    ALCClassObjectFactory *factory = [[ALCClassObjectFactory alloc] initWithType:type];

    [factory resolveWithStack:stack
                 resolvedFlag:&resolved
                        block:^{
                            XCTFail(@"Should not be called"); }];
    // Nothing to validate here.
}

-(void) testResolveWithResolvingStackWhenObjectInStack {

    NSMutableArray *stack = [[NSMutableArray alloc] init];
    __block BOOL resolved = YES;

    // Must be an object factory.
    ALCType *type = [ALCType typeWithClass:[NSString class]];
    ALCClassObjectFactory *factory = [[ALCClassObjectFactory alloc] initWithType:type];

    [stack addObject:factory];

    [factory resolveWithStack:stack
                 resolvedFlag:&resolved
                        block:^{
                            XCTFail(@"Should not be called"); }];
    // Nothing to validate here.
}

-(void) testResolveWithResolvingStackWhenMethodArgumentInStackAfterPreviousFactory {

    NSMutableArray *stack = [[NSMutableArray alloc] init];
    __block BOOL resolved = YES;

    // Must be an object factory.
    ALCType *type = [ALCType typeWithClass:[NSString class]];
    ALCClassObjectFactory *factory = [[ALCClassObjectFactory alloc] initWithType:type];

    ALCMethodArgumentDependency *methodArgDep = [ALCMethodArgumentDependency methodArgumentWithType:[ALCType typeWithClass:[NSString class]] criteria:AcClass(NSString), nil];

    [stack addObject:factory];
    [stack addObject:methodArgDep];

    XCTAssertThrowsSpecific(
                            ([factory resolveWithStack:stack
                                          resolvedFlag:&resolved
                                                 block:^{
                                                     XCTFail(@"Should not be called");
                                                 }]),
                            AlchemicResolvingException);
}

@end
