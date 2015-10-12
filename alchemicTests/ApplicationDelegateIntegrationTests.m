//
//  ApplicationDelegateIntegrationTests.m
//  alchemic
//
//  Created by Derek Clarkson on 5/10/2015.
//  Copyright © 2015 Derek Clarkson. All rights reserved.
//

#import <Alchemic/Alchemic.h>
#import <StoryTeller/StoryTeller.h>
#import <OCMock/OCMock.h>
#import "ALCTestCase.h"

@class ApplicationDelegateIntegrationTests;

@interface ADObject : NSObject
@end

@implementation ADObject
AcRegister()
@end

@interface DummyAppDelegate : NSObject<UIApplicationDelegate>
@property (nonatomic, strong) ADObject *adObject;
@end

@implementation DummyAppDelegate
AcInject(adObject)
@end

@interface ApplicationDelegateIntegrationTests : ALCTestCase
@end

@implementation ApplicationDelegateIntegrationTests {
    id<UIApplicationDelegate> _appDelegate;
}

AcInject(_appDelegate)

AcRegister(AcExternal)

- (void)setUp {

    DummyAppDelegate *dummyDelegate = [[DummyAppDelegate alloc] init];
    id mockApplication = OCMClassMock([UIApplication class]);
    OCMStub(ClassMethod([mockApplication sharedApplication])).andReturn(mockApplication);
    OCMStub([(UIApplication *)mockApplication delegate]).andReturn(dummyDelegate);

    STStartLogging(@"LogAll");
    [self setupRealContext];
    [self startContextWithClasses:@[[ADObject class], [DummyAppDelegate class], [ApplicationDelegateIntegrationTests class]]];
    AcInjectDependencies(self);
}

- (void)testApplicationDelegateInjected {
    XCTAssertNotNil(_appDelegate);
    XCTAssertNotNil(((DummyAppDelegate *)_appDelegate).adObject);
}

@end
