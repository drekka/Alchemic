//
//  MethodFactories.m
//  Alchemic
//
//  Created by Derek Clarkson on 18/02/2016.
//  Copyright © 2016 Derek Clarkson. All rights reserved.
//

@import XCTest;
#import "ALCContext.h"
#import "ALCContextImpl.h"
#import "ALCObjectFactory.h"
#import "ALCClassObjectFactory.h"
#import "ALCMethodObjectFactory.h"
#import "ALCModelSearchCriteria.h"
#import "ALCResolvable.h"
#import "ALCInternalMacros.h"
#import "ALCConstants.h"

@interface TestMFClass : NSObject
@end

@implementation TestMFClass

-(NSString *) simpleCreate {
    return @"abc";
}

-(NSString *) createWithString:(NSString *) aString andInt:(int) aInt {
    return str(@"def %@ %i",aString, aInt);
}

@end

@interface MethodFactories : XCTestCase
@end

@implementation MethodFactories{
    id<ALCContext> context;
}

-(void) setUp {
    context = [[ALCContextImpl alloc] init];
}

-(void) testTypes {
    typeof(5) x = 5;
    NSLog(@"type %s", @encode(typeof(x)));
    NSLog(@"type %s", @encode(typeof(@12)));
    NSLog(@"type %s", @encode(typeof(@"abc")));
    NSLog(@"type %s", @encode(typeof(CGSizeMake(1.0, 1.0))));
}

-(void) testNSInvocation {
    TestMFClass *testObj = [[TestMFClass alloc] init];
    NSMethodSignature *sig = [[TestMFClass class] instanceMethodSignatureForSelector:@selector(createWithString:andInt:)];
    NSInvocation *inv = [NSInvocation invocationWithMethodSignature:sig];
    inv.selector = @selector(createWithString:andInt:);

    NSString *str = @"abc";
    [inv setArgument:&str atIndex:2];
    NSNumber *x = @12;
    [inv setArgument:&x atIndex:3];

    [inv invokeWithTarget:testObj];

    id __unsafe_unretained returnObj;
    [inv getReturnValue:&returnObj];

}

-(void) testSimpleFactoryMethod {

    ALCClassObjectFactory *valueFactory = [context registerClass:[TestMFClass class]];
    ALCMethodObjectFactory *methodFactory = [context registerMethod:@selector(simpleCreate)
                                                parentObjectFactory:valueFactory
                                                               args:nil
                                                         returnType:[NSString class]];

    [context start];

    XCTAssertEqual(@"abc", methodFactory.object);
}
/*
-(void) testFactoryMethodWithArgs {

    ALCClassObjectFactory *valueFactory = [context registerClass:[TestMFClass class]];
    id<ALCDependency> arg1 = ALCString(@"ghi");
    id<ALCDependency> arg2 = ALCInt(12);
    ALCMethodObjectFactory *methodFactory = [context registerMethod:@selector(createWithString:andInt:)
                                                parentObjectFactory:valueFactory
                                                               args:@[arg1, arg2]
                                                         returnType:[NSString class]];

    [context start];

    NSString *result = methodFactory.object;
    XCTAssertEqualObjects(@"def ghi 12", result);
}
*/
@end
