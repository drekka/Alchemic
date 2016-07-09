//
//  ClassObjectFactoryTests.m
//  Alchemic
//
//  Created by Derek Clarkson on 7/07/2016.
//  Copyright © 2016 Derek Clarkson. All rights reserved.
//

@import XCTest;
@import Alchemic;
@import Alchemic.Private;
@import OCMock;

#import "XCTestCase+Alchemic.h"

@interface ClassObjectFactoryTests : XCTestCase

@end

@implementation ClassObjectFactoryTests {
    ALCClassObjectFactory *_factory;
    NSString *_testVar;
}

-(instancetype) initTest:(NSString *) aString {
    self = [super init];
    return self;
}

-(void)setUp {
    _factory = [[ALCClassObjectFactory alloc] initWithClass:[ClassObjectFactoryTests class]];
}

-(void) testConfigureWithOptionInitializerAndReferenceThrows {

    __unused id init = [[ALCClassObjectFactoryInitializer alloc] initWithObjectFactory:_factory initializer:@selector(initTest:) args:@[AcArg(NSString, AcString(@"abc"))]];

    id mockModel = OCMProtocolMock(@protocol(ALCModel));
    XCTAssertThrowsSpecific(([_factory configureWithOption:AcReference model:mockModel]), AlchemicIllegalArgumentException);
}

-(void) testRegisterInjection {
    id mockInjector = OCMProtocolMock(@protocol(ALCInjector));
    Ivar ivar = class_getInstanceVariable([self class], "_testVar");
    [_factory registerInjection:mockInjector forVariable:ivar withName:@"testVar"];
    NSArray<id<ALCDependency>> *dependencies = [self getVariable:@"_dependencies" fromObject:_factory];
    XCTAssertEqual(1u, dependencies.count);
}


@end
