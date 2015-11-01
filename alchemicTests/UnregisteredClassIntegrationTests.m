//
//  UnregisteredClassIntegrationTests.m
//  alchemic
//
//  Created by Derek Clarkson on 12/10/2015.
//  Copyright © 2015 Derek Clarkson. All rights reserved.
//

#import <Alchemic/Alchemic.h>
#import <StoryTeller/StoryTeller.h>
#import "ALCTestCase.h"

@interface UCSingleton : NSObject
@end

@implementation UCSingleton
AcRegister()
@end

@interface UCNonRegistered : NSObject
@property (nonatomic, assign) UCSingleton *ucs;
@end

@implementation UCNonRegistered
// Note - No AcRegister() means it's external.
AcInject(ucs)
@end

@interface UCExternal : NSObject
@property (nonatomic, assign) UCNonRegistered *obj;
@end

@implementation UCExternal
// Note - No AcRegister() means it's external.
AcInject(obj)
@end

@interface UCHasConstant : NSObject
@property (nonatomic, assign) NSNumber *number;
@end

@implementation UCHasConstant
// Note - No AcRegister() means it's external.
AcInject(number, AcValue(@12))
@end

@interface UnregisteredClassIntegrationTests : ALCTestCase
@end

@implementation UnregisteredClassIntegrationTests

-(void) setUp {
    [self setupRealContext];
}

-(void) testInjectingDepedenciesWithUnregistredObjectThrows {
    [self startContextWithClasses:@[[UCNonRegistered class], [UCSingleton class], [UCExternal class]]];
    UCExternal *externel = [[UCExternal alloc] init];
    XCTAssertThrowsSpecificNamed(AcInjectDependencies(externel), NSException, @"AlchemicValueNotAvailable");
}

-(void) testInjectingDependenciesWithRegisteredObject {
    [self startContextWithClasses:@[[UCNonRegistered class], [UCSingleton class]]];
    UCNonRegistered *nonRegistered = [[UCNonRegistered alloc] init];
    AcInjectDependencies(nonRegistered);
    XCTAssertNotNil(nonRegistered.ucs);
}

-(void) testInjectingDepenciesWithConstant {
    [self startContextWithClasses:@[[UCHasConstant class], [UCSingleton class]]];
    UCHasConstant *lObj = [[UCHasConstant alloc] init];
    AcInjectDependencies(lObj);
    XCTAssertEqualObjects(@12, lObj.number);
}

@end
