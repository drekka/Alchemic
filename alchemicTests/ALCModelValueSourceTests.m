//
//  ALCModelValueSourceTests.m
//  Alchemic
//
//  Created by Derek Clarkson on 24/07/2015.
//  Copyright © 2015 Derek Clarkson. All rights reserved.
//
#import <OCMock/OCMock.h>
#import <Alchemic/Alchemic.h>

#import "ALCTestCase.h"
#import "ALCModelValueSource.h"
#import "ALCDependencyPostProcessor.h"
#import "ALCBuilder.h"
#import "ALCMacroProcessor.h"
#import "ALCResolvable.h"
#import "SimpleObject.h"
#import "ALCClassBuilder.h"

@interface ALCModelValueSourceTests : ALCTestCase

@end

@implementation ALCModelValueSourceTests {
	ALCModelValueSource *_source;
	NSSet<id<ALCModelSearchExpression>> * _searchExpressions;
    ALCClassBuilder *_builder;
}

-(void) setUp {

	[super setUp];
	[self setupMockContext];

	_searchExpressions = [NSSet setWithObject:AcName(@"abc")];
    _source = [[ALCModelValueSource alloc] initWithType:[SimpleObject class]
                                      searchExpressions:_searchExpressions];
    _builder = [self simpleBuilderForClass:[SimpleObject class]];
    [_builder configure];

}

#pragma mark - Callbacks

-(void) testResolveTriggersBuilderResolveAndCallback {
    [self stubMockContextToReturnBuilders:@[_builder]];
    [_source resolveWithPostProcessors:[NSSet set] dependencyStack:[NSMutableArray array]];
}

-(void) testResolveAsUnavailableIfBuilderNotAvailable {

    id<ALCBuilder> builder2 = [self externalBuilderForClass:[SimpleObject class]];
    [builder2 configure];
    [self stubMockContextToReturnBuilders:@[_builder, builder2]];

    [_source resolveWithPostProcessors:[NSSet set] dependencyStack:[NSMutableArray array]];

}

-(void) testExecutesCallbackWhenBuilderBecomesAvailable {

    id<ALCBuilder> builder2 = [self externalBuilderForClass:[SimpleObject class]];
    [builder2 configure];
    [self stubMockContextToReturnBuilders:@[builder2]];

    [_source resolveWithPostProcessors:[NSSet set] dependencyStack:[NSMutableArray array]];

    builder2.value = @"abc";

}

-(void) testCallbackDoesntTriggerUntilLastBuilderAvailable {

    id<ALCBuilder> classBuilder1 = [self externalBuilderForClass:[NSString class]];
    [classBuilder1 configure];

    id<ALCBuilder> classBuilder2 = [self externalBuilderForClass:[NSString class]];
    [classBuilder2 configure];

    [self stubMockContextToReturnBuilders:@[classBuilder1, classBuilder2]];

    [_source resolveWithPostProcessors:[NSSet set] dependencyStack:[NSMutableArray array]];


    classBuilder1.value = @"abc";

    classBuilder2.value = @"def";

}

#pragma mark - Resolving

-(void) testBasicResolving {

	[self stubMockContextToReturnBuilders:@[_builder]];

	[_source resolveWithPostProcessors:[NSSet set] dependencyStack:[NSMutableArray array]];

	NSSet<id> *results = _source.values;
	XCTAssertEqual(1u, [results count]);
    XCTAssertTrue([[results anyObject] isKindOfClass:[SimpleObject class]]);
}

-(void) testResolvingSetsState {
    [self stubMockContextToReturnBuilders:@[_builder]];
    [_source resolveWithPostProcessors:[NSSet set] dependencyStack:[NSMutableArray array]];
}

-(void) testResolveExecutesPostProcessors {

    NSSet<id<ALCBuilder>> *builders = [NSSet setWithObject:_builder];
	[self stubMockContextToReturnBuilders:builders.allObjects];

	id mockPostProcessor = OCMProtocolMock(@protocol(ALCDependencyPostProcessor));
	OCMExpect([mockPostProcessor process:builders]).andReturn(builders);

	[_source resolveWithPostProcessors:[NSSet setWithObject:mockPostProcessor] dependencyStack:[NSMutableArray array]];

	NSSet<id> *results = _source.values;
	XCTAssertEqual(1u, [results count]);
	XCTAssertTrue([[results anyObject] isKindOfClass:[SimpleObject class]]);
	OCMVerifyAll(mockPostProcessor);
}

-(void) testBasicResolvingFailsToFindCandidates {
	[self stubMockContextToReturnBuilders:@[]];
	XCTAssertThrowsSpecificNamed([_source resolveWithPostProcessors:[NSSet set] dependencyStack:[NSMutableArray array]], NSException, @"AlchemicNoCandidateBuildersFound");

}

-(void) testResolversReturnEmptySet {

    NSSet<id<ALCBuilder>> *builders = [NSSet setWithObject:_builder];
    [self stubMockContextToReturnBuilders:builders.allObjects];

	id mockPostProcessor = OCMProtocolMock(@protocol(ALCDependencyPostProcessor));
	OCMExpect([mockPostProcessor process:builders]).andReturn([NSSet set]);

	XCTAssertThrowsSpecificNamed([_source resolveWithPostProcessors:[NSSet setWithObject:mockPostProcessor] dependencyStack:[NSMutableArray array]], NSException, @"AlchemicNoCandidateBuildersFound");
	OCMVerifyAll(mockPostProcessor);
}


@end
