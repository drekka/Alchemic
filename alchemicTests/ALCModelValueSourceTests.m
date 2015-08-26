//
//  ALCModelValueSourceTests.m
//  Alchemic
//
//  Created by Derek Clarkson on 24/07/2015.
//  Copyright © 2015 Derek Clarkson. All rights reserved.
//
#import <OCMock/OCMock.h>
#import "ALCTestCase.h"
#import "ALCModelValueSource.h"
#import "ALCDependencyPostProcessor.h"
#import "ALCBuilder.h"
#import "ALCMacroProcessor.h"
#import "ALCobjectBuilder.h"

@interface ALCModelValueSourceTests : ALCTestCase

@end

@implementation ALCModelValueSourceTests {
	ALCModelValueSource *_source;
	NSSet<id<ALCModelSearchExpression>> * _searchExpressions;
    id _mockBuilder;
}

-(void) setUp {

	[super setUp];
	[self setupMockContext];

	_searchExpressions = [NSSet setWithObject:AcName(@"abc")];
    _source = [[ALCModelValueSource alloc] initWithType:[NSString class] searchExpressions:_searchExpressions];

    _mockBuilder = OCMClassMock([ALCObjectBuilder class]); // Cant use protocol mocks due to KVO.
    OCMStub([(id<ALCBuilder>)_mockBuilder value]).andReturn(@"def");

}

#pragma mark - State

-(void) testResolveMatchesBuilderAvailableWhenBuilderNotAvailable {
    [self stubModelToReturnBuilders:@[_mockBuilder]];
    [_source resolveWithPostProcessors:[NSSet set] dependencyStack:[NSMutableArray array]];
    XCTAssertFalse(_source.available);
}

-(void) testResolveMatchesBuilderAvailableWhenBuilderAvailable {
    [self stubModelToReturnBuilders:@[_mockBuilder]];
    OCMStub([_mockBuilder available]).andReturn(YES);
    [_source resolveWithPostProcessors:[NSSet set] dependencyStack:[NSMutableArray array]];
    XCTAssertTrue(_source.available);
}

-(void) testResolveUnavailableWhenBuildersMixedAvailable {

    id mockBuilder2 = OCMClassMock([ALCObjectBuilder class]); // Allows KVO
    OCMStub([(id<ALCBuilder>)_mockBuilder available]).andReturn(YES);
    OCMStub([(id<ALCBuilder>)mockBuilder2 available]).andReturn(NO);
    [self stubModelToReturnBuilders:@[_mockBuilder, mockBuilder2]];

    [_source resolveWithPostProcessors:[NSSet set] dependencyStack:[NSMutableArray array]];

    XCTAssertFalse(_source.available);
}

-(void) testKVOTriggersWhenStateChanges {

    // Use an external class builder so we can control the available setting
    id<ALCBuilder> classBuilder = [self simpleBuilderForClass:[NSString class]];
    [classBuilder.macroProcessor addMacro:AcExternal];
    [classBuilder configure];
    [self stubModelToReturnBuilders:@[classBuilder]];

    [_source resolveWithPostProcessors:[NSSet set] dependencyStack:[NSMutableArray array]];

    XCTAssertFalse(_source.available);

    classBuilder.value = @"abc";

    XCTAssertTrue(_source.available);

}

-(void) testKVODoesntTriggerUntilLastBuilderAvailable {

    id<ALCBuilder> classBuilder1 = [self simpleBuilderForClass:[NSString class]];
    [classBuilder1.macroProcessor addMacro:AcExternal];
    [classBuilder1 configure];

    id<ALCBuilder> classBuilder2 = [self simpleBuilderForClass:[NSString class]];
    [classBuilder2.macroProcessor addMacro:AcExternal];
    [classBuilder2 configure];

    [self stubModelToReturnBuilders:@[classBuilder1, classBuilder2]];

    [_source resolveWithPostProcessors:[NSSet set] dependencyStack:[NSMutableArray array]];

    XCTAssertFalse(_source.available);

    classBuilder1.value = @"abc";
    XCTAssertFalse(_source.available);

    classBuilder2.value = @"def";
    XCTAssertTrue(_source.available);

}

-(void) testStateWhenBuildersAreAlreadyAvailable {


    id<ALCBuilder> classBuilder1 = [self simpleBuilderForClass:[NSString class]];
    [classBuilder1.macroProcessor addMacro:AcExternal];
    [classBuilder1 configure];
    classBuilder1.value = @"abc";

    id<ALCBuilder> classBuilder2 = [self simpleBuilderForClass:[NSString class]];
    [classBuilder2.macroProcessor addMacro:AcExternal];
    [classBuilder2 configure];
    classBuilder2.value = @"def";

    [self stubModelToReturnBuilders:@[classBuilder1, classBuilder2]];
    [_source resolveWithPostProcessors:[NSSet set] dependencyStack:[NSMutableArray array]];

    XCTAssertTrue(_source.available);
}

#pragma mark - Resolving

-(void) testBasicResolving {

	[self stubModelToReturnBuilders:@[_mockBuilder]];

	[_source resolveWithPostProcessors:[NSSet set] dependencyStack:[NSMutableArray array]];

	NSSet<id> *results = _source.values;
	XCTAssertEqual(1u, [results count]);
	XCTAssertEqualObjects(@"def", [results anyObject]);
}

-(void) testResolvingSetsState {
    [self stubModelToReturnBuilders:@[_mockBuilder]];
    [_source resolveWithPostProcessors:[NSSet set] dependencyStack:[NSMutableArray array]];
}

-(void) testResolversCalled {

    NSSet<id<ALCBuilder>> *builders = [NSSet setWithObject:_mockBuilder];
	[self stubModelToReturnBuilders:builders.allObjects];

	id mockPostProcessor = OCMProtocolMock(@protocol(ALCDependencyPostProcessor));
	OCMExpect([mockPostProcessor process:builders]).andReturn(builders);

	[_source resolveWithPostProcessors:[NSSet setWithObject:mockPostProcessor] dependencyStack:[NSMutableArray array]];

	NSSet<id> *results = _source.values;
	XCTAssertEqual(1u, [results count]);
	XCTAssertEqualObjects(@"def", [results anyObject]);
	OCMVerifyAll(mockPostProcessor);
}

-(void) testBasicResolvingFailsToFindCandidates {
	[self stubModelToReturnBuilders:@[]];
	XCTAssertThrowsSpecificNamed([_source resolveWithPostProcessors:[NSSet set] dependencyStack:[NSMutableArray array]], NSException, @"AlchemicNoCandidateBuildersFound");

}

-(void) testResolversReturnEmptySet {

    NSSet<id<ALCBuilder>> *builders = [NSSet setWithObject:_mockBuilder];
    [self stubModelToReturnBuilders:builders.allObjects];

	id mockPostProcessor = OCMProtocolMock(@protocol(ALCDependencyPostProcessor));
	OCMExpect([mockPostProcessor process:builders]).andReturn([NSSet set]);

	XCTAssertThrowsSpecificNamed([_source resolveWithPostProcessors:[NSSet setWithObject:mockPostProcessor] dependencyStack:[NSMutableArray array]], NSException, @"AlchemicNoCandidateBuildersFound");
	OCMVerifyAll(mockPostProcessor);
}


#pragma mark - Internal

-(void) stubModelToReturnBuilders:(NSArray<id<ALCBuilder>> *) builders {
	OCMStub([self.mockContext executeOnBuildersWithSearchExpressions:_searchExpressions processingBuildersBlock:OCMOCK_ANY]).andDo(^(NSInvocation *inv){
		__unsafe_unretained ProcessBuilderBlock processBuilderBlock;
		[inv getArgument:&processBuilderBlock atIndex:3];
		processBuilderBlock([NSSet setWithArray:builders]);
	});
}


@end
