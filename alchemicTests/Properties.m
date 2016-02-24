//
//  SingletonTests.m
//  Alchemic
//
//  Created by Derek Clarkson on 5/02/2016.
//  Copyright © 2016 Derek Clarkson. All rights reserved.
//

@import XCTest;
@import UIKit;

#import "ALCContext.h"
#import "ALCContextImpl.h"
#import "ALCClassObjectFactory.h"
#import "ALCDependency.h"
#import "ALCConstants.h"

@interface SWPTestClass : NSObject
@property (nonatomic, strong) NSString *aString;
@property (nonatomic, assign) int aInt;
@property (nonatomic, assign) double aDouble;
@property (nonatomic, assign) float aFloat;
@property (nonatomic, assign) CGRect aCGRect;
@end

@implementation SWPTestClass
@end

@interface Properties : XCTestCase
@end

@implementation Properties

-(void) testIntConstant {
    [self runTestWithConstant:ALCInt(5) targetVariable:@"aInt" validationBlock:^(SWPTestClass *singleton) {
        XCTAssertEqual(5, singleton.aInt);
    }];
}

/*
-(void) testInstantiationWithProperty {

    id<ALCContext> context = [[ALCContextImpl alloc] init];
    ALCClassObjectFactory *valueFactory = [context registerClass:[SWPTestClass class]];
    id<ALCDependency> propertyValue = ALCString(@"abc");
    [valueFactory registerDependency:propertyValue forVariable:@"aString"];

    [context start];

    XCTAssertTrue(valueFactory.ready);

    SWPTestClass *singleton = valueFactory.object;

    XCTAssertTrue([singleton isKindOfClass:[SWPTestClass class]]);
    NSString *prop = singleton.aString;
    XCTAssertEqual(@"abc", prop);
}
*/
-(void) testInstantiationWithIncorrectPropertyType {

    id<ALCContext> context = [[ALCContextImpl alloc] init];
    ALCClassObjectFactory *valueFactory = [context registerClass:[SWPTestClass class]];
    id<ALCDependency> propertyValue = ALCInt(12);
    [valueFactory registerDependency:propertyValue forVariable:@"aString"];

    @try {
        [context start];
        XCTFail(@"Exception not thrown");
    }
    @catch (NSException *e) {
        XCTAssertEqualObjects(@"Resolved value of type __NSCFNumber cannot be cast to variable '_aString' (NSString)", e.reason);
    }
}

-(void) runTestWithConstant:(id<ALCDependency>) dependency
             targetVariable:(NSString *) variableName
            validationBlock:(void (^)(SWPTestClass *)) validationBlock {

    id<ALCContext> context = [[ALCContextImpl alloc] init];
    ALCClassObjectFactory *valueFactory = [context registerClass:[SWPTestClass class]];
    [valueFactory registerDependency:dependency forVariable:variableName];

    [context start];

    SWPTestClass *singleton = valueFactory.object;
    validationBlock(singleton);
}

@end
