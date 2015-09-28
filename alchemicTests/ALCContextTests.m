//
//  ALCContextTests.m
//  Alchemic
//
//  Created by Derek Clarkson on 6/08/2015.
//  Copyright © 2015 Derek Clarkson. All rights reserved.
//

@import XCTest;
@import ObjectiveC;

#import "ALCTestCase.h"
#import <OCMock/OCMock.h>
#import <StoryTeller/Storyteller.h>
#import <Alchemic/Alchemic.h>

#import "ALCContext.h"
#import "ALCRuntime.h"
#import "ALCBuilder.h"
#import "SimpleObject.h"
#import "ALCModel.h"

#import "ALCBuilder.h"
#import "ALCBuilder.h"

@interface ALCContextTests : ALCTestCase

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

    id mockBuilder = OCMClassMock([ALCBuilder class]);
    NSSet<ALCBuilder *> *builders = [NSSet setWithObject:mockBuilder];
    OCMStub([_mockModel buildersForSearchExpressions:expressions]).andReturn(builders);
    OCMStub([_mockModel classBuildersFromBuilders:builders]).andReturn(builders);

    SimpleObject *object = [[SimpleObject alloc] init];
    OCMExpect([mockBuilder injectDependencies:object]);

    [_context injectDependencies:object];

    OCMVerifyAll(mockBuilder);

}

-(void) testResolveBuilderDependencies {

    id mockBuilder = OCMClassMock([ALCBuilder class]);
    NSSet<ALCBuilder *> *builders = [NSSet setWithObject:mockBuilder];
    OCMStub([_mockModel numberBuilders]).andReturn(1u);
    OCMStub([_mockModel allBuilders]).andReturn(builders);

    OCMExpect([mockBuilder resolve]);
    OCMStub([mockBuilder valueClass]).andReturn([NSString class]);

    ignoreSelectorWarnings(
                           [_context performSelector:@selector(resolveBuilderDependencies)];
                           )

    OCMVerifyAll(mockBuilder);
}

-(void) testRegisterDependencyInClassBuilder {
    ALCBuilder *classBuilder = [self simpleBuilderForClass:[SimpleObject class]];
    [_context registerClassBuilder:classBuilder variableDependency:@"aStringProperty", nil];
}

#pragma mark - Invoking builders

-(void) testInvokeMethodBuildersSingleBuilder {

    ALCName *nameLocator = AcName(@"abc");

    id mockBuilder = OCMClassMock([ALCBuilder class]);
    OCMStub([(ALCBuilder *)mockBuilder type]).andReturn(ALCBuilderPersonalityTypeMethod);
    OCMStub([mockBuilder invokeWithArgs:@[@"def"]]).andReturn(@"xyz");

    OCMStub([_mockModel buildersForSearchExpressions:[OCMArg checkWithBlock:^BOOL(id arg){
        return [(NSSet *)arg containsObject:nameLocator];
    }]]).andReturn([NSSet setWithObject:mockBuilder]);

    id results = [_context invokeMethodBuilders:nameLocator, @"def", nil];
    XCTAssertEqualObjects(@"xyz", results);

    OCMVerify([mockBuilder invokeWithArgs:OCMOCK_ANY]);
}

-(void) testInvokeMethodBuildersWithMulitpleBuilders {

    ALCClass *classLocator = AcClass([SimpleObject class]);

    id mockBuilder1 = OCMClassMock([ALCBuilder class]);
    OCMStub([mockBuilder1 invokeWithArgs:@[@"def"]]).andReturn(@"xyz");
    OCMStub([(ALCBuilder *)mockBuilder1 type]).andReturn(ALCBuilderPersonalityTypeMethod);

    id mockBuilder2 = OCMClassMock([ALCBuilder class]);
    OCMStub([mockBuilder2 invokeWithArgs:@[@"def"]]).andReturn(@12);
    OCMStub([(ALCBuilder *)mockBuilder2 type]).andReturn(ALCBuilderPersonalityTypeMethod);

    OCMStub([_mockModel buildersForSearchExpressions:[OCMArg checkWithBlock:^BOOL(id arg){
        return [(NSSet *)arg containsObject:classLocator];
    }]]).andReturn(([NSSet setWithObjects:mockBuilder1, mockBuilder2, nil]));


    id results = [_context invokeMethodBuilders:classLocator, @"def", nil];
    XCTAssertTrue([results isKindOfClass:[NSSet class]]);
    XCTAssertEqual(2u, [results count]);
    XCTAssertTrue([results containsObject:@"xyz"]);
    XCTAssertTrue([results containsObject:@12]);

    OCMVerify([mockBuilder1 invokeWithArgs:OCMOCK_ANY]);
    OCMVerify([mockBuilder2 invokeWithArgs:OCMOCK_ANY]);
}


@end
