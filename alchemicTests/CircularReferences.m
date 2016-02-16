//
//  SingletonCircularReferences.m
//  Alchemic
//
//  Created by Derek Clarkson on 9/02/2016.
//  Copyright © 2016 Derek Clarkson. All rights reserved.
//

@import XCTest;

#import "ALCContext.h"
#import "ALCContextImpl.h"
#import "ALCClassObjectFactory.h"
#import "ALCResolvable.h"
#import "ALCModelSearchCriteria.h"
#import "ALCModelDependency.h"

@interface Singleton1 : NSObject
@property (nonatomic, strong) id singleton2;
@end

@implementation Singleton1
@end

@interface Singleton2 : NSObject
@property (nonatomic, strong) id singleton1;
@end

@implementation Singleton2
@end

@interface CircularReferences : XCTestCase

@end

@implementation CircularReferences

-(void) testDependencyCircularReferences {

    id<ALCContext> context = [[ALCContextImpl alloc] init];

    ALCClassObjectFactory *singleton1 = [context registerClass:[Singleton1 class]];
    ALCModelSearchCriteria *criteria1 = [ALCModelSearchCriteria searchCriteriaForClass:[Singleton2 class]];
    id<ALCResolvable> modelDependency1 = [[ALCModelDependency alloc] initWithCriteria:criteria1];
    [singleton1 registerDependency:modelDependency1 forVariable:@"singleton2"];

    ALCClassObjectFactory *singleton2 = [context registerClass:[Singleton2 class]];
    ALCModelSearchCriteria *criteria2 = [ALCModelSearchCriteria searchCriteriaForClass:[Singleton1 class]];
    id<ALCResolvable> modelDependency2 = [[ALCModelDependency alloc] initWithCriteria:criteria2];
    [singleton2 registerDependency:modelDependency2 forVariable:@"singleton1"];

    @try {
        [context start];
        XCTFail(@"Exception not thrown");
    }
    @catch (NSException *e) {
        XCTAssertEqualObjects(@"AlchemicCircularDependency", e.name);
        XCTAssertEqualObjects(@"Circular dependency detected: Singleton1.singleton2 -> Singleton2.singleton1 -> Singleton1", e.reason);
    }

}

@end
