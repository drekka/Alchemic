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
#import "ALCDependency.h"
#import "ALCModelSearchCriteria.h"
#import "ALCObjectFactory.h"
#import "ALCModelDependency.h"
#import "ALCClassObjectFactoryInitializer.h"

@interface Singleton1 : NSObject
@property (nonatomic, strong) id singleton2;
-(instancetype) initWithSingleton:(id) singleton2;
@end

@implementation Singleton1
-(instancetype) initWithSingleton:(id) singleton2 {
    if (self) {
        self.singleton2 = singleton2;
    }
    return self;
}
@end

@interface Singleton2 : NSObject
@property (nonatomic, strong) id singleton1;
-(instancetype) initWithSingleton:(id) singleton1;
@end

@implementation Singleton2
-(instancetype) initWithSingleton:(id) singleton1 {
    if (self) {
        self.singleton1 = singleton1;
    }
    return self;
}
@end

@interface CircularReferences : XCTestCase

@end

@implementation CircularReferences {
    id<ALCContext> _context;
}

-(void) setUp {
    _context = [[ALCContextImpl alloc] init];
}

-(void) testPropertyToProperty {
    id<ALCObjectFactory> singleton1 = [self singletonForClass:[Singleton1 class] withInjection:@"singleton2" ofType:[Singleton2 class]];
    id<ALCObjectFactory> singleton2 = [self singletonForClass:[Singleton2 class] withInjection:@"singleton1" ofType:[Singleton1 class]];
    [_context start];
    [self validateSingleton1:singleton1 singleton2:singleton2];
}

-(void) testInitializerToInitializer {

    __unused id s1 = [self singletonForClass:[Singleton1 class]
                              withInitializer:@selector(initWithSingleton:)
                                   arguClass:[Singleton2 class]];
    __unused id s2 = [self singletonForClass:[Singleton2 class]
                              withInitializer:@selector(initWithSingleton:)
                                   arguClass:[Singleton1 class]];
    @try {
        [_context start];
        XCTFail(@"Exception not thrown");
    }
    @catch (NSException *exception) {
        XCTAssertEqualObjects(@"AlchemicCircularDependency", exception.name);
    }
}

-(void) testPropertyToInitializer {
    id<ALCObjectFactory> singleton1 = [self singletonForClass:[Singleton1 class] withInjection:@"singleton2" ofType:[Singleton2 class]];
    id<ALCObjectFactory> singleton2 = [self singletonForClass:[Singleton2 class]
                                               withInitializer:@selector(initWithSingleton:)
                                                    arguClass:[Singleton1 class]];
    [_context start];
    [self validateSingleton1:singleton1 singleton2:singleton2];
}

-(void) testInitializerToProperty {
    id<ALCObjectFactory> singleton1 = [self singletonForClass:[Singleton1 class]
                                               withInitializer:@selector(initWithSingleton:)
                                                    arguClass:[Singleton2 class]];
    id<ALCObjectFactory> singleton2 = [self singletonForClass:[Singleton2 class] withInjection:@"singleton1" ofType:[Singleton1 class]];
    [_context start];
    [self validateSingleton1:singleton1 singleton2:singleton2];
}

#pragma mark - Internal

-(id<ALCObjectFactory>) singletonForClass:(Class) factoryClass withInitializer:(SEL) initializer arguClass:(Class) argClass {
    ALCClassObjectFactory *singleton = [_context registerClass:factoryClass];
    ALCModelSearchCriteria *classCriteria = [ALCModelSearchCriteria searchCriteriaForClass:argClass];
    id<ALCDependency> modelDependency = [[ALCModelDependency alloc] initWithCriteria:classCriteria];
    __unused id _2 = [[ALCClassObjectFactoryInitializer alloc] initWithObjectFactory:singleton
                                                                         initializer:initializer
                                                                                args:@[modelDependency]];
    return singleton;
}

-(id<ALCObjectFactory>) singletonForClass:(Class) factoryClass withInjection:(NSString *) propertyName ofType:(Class) injectionType {
    ALCClassObjectFactory *singleton = [_context registerClass:factoryClass];
    ALCModelSearchCriteria *criteria = [ALCModelSearchCriteria searchCriteriaForClass:injectionType];
    id<ALCDependency> modelDependency = [[ALCModelDependency alloc] initWithCriteria:criteria];
    [singleton registerDependency:modelDependency forVariable:propertyName];
    return singleton;
}

-(void) validateSingleton1:(id<ALCObjectFactory>) singleton1 singleton2:(id<ALCObjectFactory>) singleton2 {
    XCTAssertTrue(singleton1.ready);
    XCTAssertTrue(singleton2.ready);
    Singleton1 *s1 = singleton1.object;
    Singleton2 *s2 = singleton2.object;
    XCTAssertEqual(s1, s2.singleton1);
    XCTAssertEqual(s2, s1.singleton2);
}

@end
