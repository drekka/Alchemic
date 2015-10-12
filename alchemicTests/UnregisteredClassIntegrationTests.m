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

@interface UCObject : NSObject
@property (nonatomic, assign) UCSingleton *ucs;
@end

@implementation UCObject
AcInject(ucs)
@end

@interface UnregisteredClassIntegrationTests : ALCTestCase
@end

@implementation UnregisteredClassIntegrationTests {
    UCObject *_obj;
}

AcRegister(AcExternal)
AcInject(_obj);

-(void) setUp {
    [self setupRealContext];
}

-(void) testAccessingUnregistredObjectThrows {
    [self startContextWithClasses:@[[UCObject class], [UCSingleton class], [UnregisteredClassIntegrationTests class]]];
    XCTAssertThrowsSpecificNamed(AcInjectDependencies(self), NSException, @"AlchemicValueNotAvailable");
}

-(void) testInjectingUnregisteredObject {
    [self startContextWithClasses:@[[UCObject class], [UCSingleton class], [UnregisteredClassIntegrationTests class]]];
    UCObject *lObj = [[UCObject alloc] init];
    AcInjectDependencies(lObj);
    XCTAssertNotNil(lObj.ucs);
}

@end
