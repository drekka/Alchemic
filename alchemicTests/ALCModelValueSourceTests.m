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
#import "ALCClassBuilder.h"
#import "ALCDependencyPostProcessor.h"

@interface ALCModelValueSourceTests : ALCTestCase

@end

@implementation ALCModelValueSourceTests {
	ALCModelValueSource *_source;
	NSSet<id<ALCModelSearchExpression>> * _searchExpressions;
}

-(void) setUp {

	[super setUp];
	[self setupMockContext];

	_searchExpressions = [NSSet setWithObject:AcName(@"abc")];
    _source = [[ALCModelValueSource alloc] initWithType:[NSString class] searchExpressions:_searchExpressions];
}

-(void) testBasicResolving {

	id<ALCBuilder> builder = [[ALCClassBuilder alloc] initWithValueClass:[NSString class]];
	builder.value = @"def";
	NSSet<id<ALCBuilder>> *builders =[NSSet setWithObject:builder];
	[self stubExecuteOnBuilders:builders];

	[_source resolveWithPostProcessors:[NSSet set]];

	NSSet<id> *results = _source.values;
	XCTAssertEqual(1u, [results count]);
	XCTAssertEqualObjects(@"def", [results anyObject]);
}

-(void) testResolversCalled {

	id<ALCBuilder> builder = [[ALCClassBuilder alloc] initWithValueClass:[NSString class]];
	builder.value = @"def";
	NSSet<id<ALCBuilder>> *builders =[NSSet setWithObject:builder];
	[self stubExecuteOnBuilders:builders];

	id mockPostProcessor = OCMProtocolMock(@protocol(ALCDependencyPostProcessor));
	OCMExpect([mockPostProcessor process:builders]).andReturn(builders);

	[_source resolveWithPostProcessors:[NSSet setWithObject:mockPostProcessor]];

	NSSet<id> *results = _source.values;
	XCTAssertEqual(1u, [results count]);
	XCTAssertEqualObjects(@"def", [results anyObject]);
	OCMVerifyAll(mockPostProcessor);
}

-(void) testBasicResolvingFailsToFindCandidates {
	[self stubExecuteOnBuilders:[NSSet set]];
	XCTAssertThrowsSpecificNamed([_source resolveWithPostProcessors:[NSSet set]], NSException, @"AlchemicNoCandidateBuildersFound");

}

-(void) testResolversReturnEmptySet {

	id<ALCBuilder> builder = [[ALCClassBuilder alloc] initWithValueClass:[NSString class]];
	builder.value = @"def";
	NSSet<id<ALCBuilder>> *builders =[NSSet setWithObject:builder];
	[self stubExecuteOnBuilders:builders];

	id mockPostProcessor = OCMProtocolMock(@protocol(ALCDependencyPostProcessor));
	OCMExpect([mockPostProcessor process:builders]).andReturn([NSSet set]);

	XCTAssertThrowsSpecificNamed([_source resolveWithPostProcessors:[NSSet setWithObject:mockPostProcessor]], NSException, @"AlchemicNoCandidateBuildersFound");
	OCMVerifyAll(mockPostProcessor);
}


#pragma mark - Internal

-(void) stubExecuteOnBuilders:(NSSet<id<ALCBuilder>> *) builders {
	OCMStub([self.mockContext executeOnBuildersWithSearchExpressions:_searchExpressions processingBuildersBlock:OCMOCK_ANY]).andDo(^(NSInvocation *inv){
		__unsafe_unretained ProcessBuilderBlock processBuilderBlock;
		[inv getArgument:&processBuilderBlock atIndex:3];
		processBuilderBlock(builders);
	});
}


@end
