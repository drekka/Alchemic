//
//  SingletonTests.m
//  Alchemic
//
//  Created by Derek Clarkson on 5/02/2016.
//  Copyright © 2016 Derek Clarkson. All rights reserved.
//

@import XCTest;

#import <Alchemic/Alchemic.h>

@interface SingletonWithProperty : NSObject
@property (nonatomic, strong) NSString *prop;
@end

@implementation SingletonWithProperty
@end

@interface SingletonWithPropertiesTests : XCTestCase
@end

@implementation SingletonWithPropertiesTests

-(void) testInstantiationWithProperty {

    id<ALCContext> context = [[ALCContextImpl alloc] init];
    id<ALCObjectFactory> valueFactory = [context registerClass:[SingletonWithProperty class]];
    id<ALCResolvable> propertyValue = [[ALCConstantValue alloc] initWithValue:@"abc"];
    [valueFactory registerDependency:propertyValue forVariable:@"prop"];

    [context start];

    XCTAssertTrue(valueFactory.resolved);

    SingletonWithProperty *singleton = valueFactory.object;

    XCTAssertTrue([singleton isKindOfClass:[SingletonWithProperty class]]);
    NSString *prop = singleton.prop;
    XCTAssertEqual(@"abc", prop);
}

-(void) testInstantiationWithIncorrectPropertyType {

    id<ALCContext> context = [[ALCContextImpl alloc] init];
    id<ALCObjectFactory> valueFactory = [context registerClass:[SingletonWithProperty class]];
    id<ALCResolvable> propertyValue = [[ALCConstantValue alloc] initWithValue:@12];
    [valueFactory registerDependency:propertyValue forVariable:@"prop"];


    @try {
        [context start];
        XCTFail(@"Exception not thrown");
    }
    @catch (NSException *e) {
        XCTAssertEqualObjects(@"Resolved value of type __NSCFNumber cannot be cast to variable '_prop' (NSString)", e.reason);
    }
}

@end
