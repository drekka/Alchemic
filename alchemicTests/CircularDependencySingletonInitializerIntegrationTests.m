//
//  CircularDependencySingletonInitializerIntegrationTests.m
//  alchemic
//
//  Created by Derek Clarkson on 15/10/2015.
//  Copyright © 2015 Derek Clarkson. All rights reserved.
//
#import "ALCTestCase.h"
#import <StoryTeller/StoryTeller.h>
#import <Alchemic/Alchemic.h>

@class CDSIInitializer;

// Tests a circular dependency between a class and a class that is created with an initializer. The fact that the singleton class is refering to the initializer craeted class via a property should break the dependency cycle and allow this setup to buil successfully. The singleton should be created first, followed by the initializer driven class and finally the initializer class should be injected back into the singleton.

// ------------

@interface CDSISingleton: NSObject
@property (nonatomic, strong, readonly) CDSIInitializer *initializer;
@end

@implementation CDSISingleton
AcRegister()
AcInject(initializer)
@end

// ------------

@interface CDSIInitializer: NSObject
@property (nonatomic, strong, readonly) CDSISingleton *singleton;
@end

@implementation CDSIInitializer
AcRegister()
AcInitializer(initWithSingleton:, AcArg(CDSISingleton, AcName(@"CDSISingleton")))
-(instancetype) initWithSingleton:(CDSISingleton *) singleton {
    self = [super init];
    if (self) {
        _singleton = singleton;
    }
    return self;
}
@end

// ------------

@interface CircularDependencySingletonInitializerIntegrationTests : ALCTestCase
@end

@implementation CircularDependencySingletonInitializerIntegrationTests {
    CDSISingleton *_singleton;
    CDSIInitializer *_initializer;
}

AcInject(singleton)
AcInject(initializer)

-(void) testCircularDepBetweenInitializerAndSingleton {
    [self setupRealContext];
    [self startContextWithClasses:@[[CDSISingleton class], [CDSIInitializer class], [CircularDependencySingletonInitializerIntegrationTests class]]];
    AcInjectDependencies(self);

    XCTAssertNotNil(_singleton);
    XCTAssertNotNil(_singleton.initializer);
    XCTAssertNotNil(_initializer);
    XCTAssertNotNil(_initializer.singleton);

}

@end
