//
//  InvokeIntegrationTests.m
//  alchemic
//
//  Created by Derek Clarkson on 18/08/2015.
//  Copyright © 2015 Derek Clarkson. All rights reserved.
//

#import <Alchemic/Alchemic.h>
#import "ALCTestCase.h"
#import <StoryTeller/StoryTeller.h>

// Scenario: Using an initializer on a factory with a non-managed value. Resulting object should be injected.

@interface IVSingleton : NSObject
@end

@implementation IVSingleton
AcRegister()
@end

@interface IVFactory : NSObject
@property (nonatomic, strong, readonly) IVSingleton *injectedSingleton;
@property (nonatomic, strong, readonly) NSString *initializerInjectedString;
-(instancetype) initWithString:(NSString *) aString;
@end

@implementation IVFactory

AcInject(injectedSingleton)

// Note missing arg definitions
AcInitializer(initWithString:, AcFactory)
-(instancetype) initWithString:(NSString *) aString {
    self = [super init];
    if (self) {
        _initializerInjectedString = aString;
    }
    return self;
}
@end

@interface InvokeIntegrationTests : ALCTestCase
@end

@implementation InvokeIntegrationTests

-(void) testIntegrationInvokingAFactoryInititializer {
    STStartLogging(@"LogAll");

    [self setupRealContext];
    [self startContextWithClasses:@[[IVSingleton class], [IVFactory class]]];

    IVFactory *result = AcInvoke(AcName(@"IVFactory initWithString:"), @"def");

    XCTAssertNotNil(result);
    XCTAssertNotNil(result.injectedSingleton);
    XCTAssertEqualObjects(@"def", result.initializerInjectedString);

}

-(void) testIntegrationInvokingAFactoryInititializerWithMissingArgsPassesNil {

    [self setupRealContext];
    [self startContextWithClasses:@[[IVSingleton class], [IVFactory class]]];

    IVFactory *result = AcInvoke(AcName(@"IVFactory initWithString:"));

    XCTAssertNotNil(result);
    XCTAssertNotNil(result.injectedSingleton);
    XCTAssertNil(result.initializerInjectedString);
    
}

@end
