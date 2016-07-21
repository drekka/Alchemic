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




@end
