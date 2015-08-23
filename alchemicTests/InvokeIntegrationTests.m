//
//  InvokeIntegrationTests.m
//  alchemic
//
//  Created by Derek Clarkson on 18/08/2015.
//  Copyright © 2015 Derek Clarkson. All rights reserved.
//

#import <Alchemic/Alchemic.h>
#import "ALCTestCase.h"

// Scenario: Using an initializer on a factory with a non-managed value. Resulting object should be injected.

@interface IVSingleton : NSObject
@end

@implementation IVSingleton
AcRegister()
@end

@interface IVFactory : NSObject
@property (nonatomic, strong, readonly) IVSingleton *singleton;
@property (nonatomic, strong, readonly) NSString *aString;
-(instancetype) initWithString:(NSString *) aString;
@end

@implementation IVFactory

AcInject(singleton)

// Note missing arg definitions
AcInitializer(initWithString:, AcFactory)
-(instancetype) initWithString:(NSString *) aString {
    self = [super init];
    if (self) {
        _aString = aString;
    }
    return self;
}
@end

@interface InvokeIntegrationTests : ALCTestCase
@end

@implementation InvokeIntegrationTests

-(void) testInvokingAFactoryInititializer {

    [self setupRealContext];
    [self startContextWithClasses:@[[IVSingleton class], [IVFactory class]]];

    IVFactory *result = AcInvoke(AcName(@"IVFactory initWithString:"), @"def");

    XCTAssertNotNil(result);
    XCTAssertNotNil(result.singleton);
    XCTAssertEqualObjects(@"def", result.aString);

}

-(void) testInvokingAFactoryInititializerWithMissingArgsPassesNil {

    [self setupRealContext];
    [self startContextWithClasses:@[[IVSingleton class], [IVFactory class]]];

    IVFactory *result = AcInvoke(AcName(@"IVFactory initWithString:"));

    XCTAssertNotNil(result);
    XCTAssertNotNil(result.singleton);
    XCTAssertNil(result.aString);
    
}

@end
