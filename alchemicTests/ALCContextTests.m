//
//  ALCContextTests.m
//  Alchemic
//
//  Created by Derek Clarkson on 6/08/2015.
//  Copyright © 2015 Derek Clarkson. All rights reserved.
//

@import XCTest;
@import ObjectiveC;
#import <OCMock/OCMock.h>

#import <Alchemic/Alchemic.h>

#import "ALCContext.h"
#import "ALCClassBuilder.h"
#import "ALCRuntime.h"
#import "ALCBuilder.h"
#import "SimpleObject.h"
#import "ALCModel.h"
#import "ALCAbstractMethodBuilder.h"

@interface ALCContextTests : XCTestCase

@end

@implementation ALCContextTests {
    ALCContext *_context;
    id _mockRuntime;
    id _mockModel;
}

-(void) setUp {
    _mockRuntime = OCMClassMock([ALCRuntime class]);
    _mockModel = OCMClassMock([ALCModel class]);
    _context = [[ALCContext alloc] init];
    Ivar modelVar = class_getInstanceVariable([ALCContext class], "_model");
    object_setIvar(_context, modelVar, _mockModel);
}


-(void) testInjectDependencies {

    NSSet<id<ALCModelSearchExpression>> *expressions = [NSSet setWithObject:AcClass(SimpleObject)];
    OCMStub([_mockRuntime searchExpressionsForClass:[SimpleObject class]]).andReturn(expressions);

    id mockBuilder = OCMProtocolMock(@protocol(ALCBuilder));
    NSSet<id<ALCBuilder>> *builders = [NSSet setWithObject:mockBuilder];
    OCMStub([_mockModel buildersForSearchExpressions:expressions]).andReturn(builders);
    OCMStub([_mockModel classBuildersFromBuilders:builders]).andReturn(builders);

    SimpleObject *object = [[SimpleObject alloc] init];
    OCMExpect([mockBuilder injectValueDependencies:object]);

    [_context injectDependencies:object];

    OCMVerifyAll(mockBuilder);

}

-(void) testResolveBuilderDependencies {

    id mockBuilder = OCMProtocolMock(@protocol(ALCBuilder));
    NSSet<id<ALCBuilder>> *builders = [NSSet setWithObject:mockBuilder];
    OCMStub([_mockModel numberBuilders]).andReturn(1u);
    OCMStub([_mockModel allBuilders]).andReturn(builders);

    OCMExpect([mockBuilder resolveWithPostProcessors:OCMOCK_ANY]);
    OCMExpect([mockBuilder validateWithDependencyStack:OCMOCK_ANY]);
    OCMStub([mockBuilder valueClass]).andReturn([NSString class]);

    ignoreSelectorWarnings(
                           [_context performSelector:@selector(resolveBuilderDependencies)];
                           )

    OCMVerifyAll(mockBuilder);
}

-(void) testRegisterDependencyInClassBuilder {
    ALCClassBuilder *classBuilder = [[ALCClassBuilder alloc] initWithValueClass:[SimpleObject class]];
    
    [_context registerClassBuilder:classBuilder variableDependency:@"aStringProperty", nil];
}

-(void) testInvokeOnMethodBuilders {

    ALCName *nameLocator = AcName(@"abc");
    id mockBuilder = OCMClassMock([ALCAbstractMethodBuilder class]);
    OCMStub([_mockModel buildersForSearchExpressions:[OCMArg checkWithBlock:^BOOL(id arg){
        return [(NSSet *)arg containsObject:nameLocator];
    }]]).andReturn([NSSet setWithObject:mockBuilder]);

    id mockInv = OCMClassMock([NSInvocation class]);
    OCMStub([mockBuilder inv]).andReturn(mockInv);

    OCMStub([mockBuilder instantiateObjectWithArguments:@[@"def"]]).andReturn(@"xyz");

    id results = [_context invokeMethodBuilders:nameLocator, AcArg(NSString, AcValue(@"def")), nil];
    XCTAssertEqualObjects(@"xyz", results);


    OCMVerify([mockBuilder instantiateObjectWithArguments:OCMOCK_ANY]);
}

@end
