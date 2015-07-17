//
//  ALCModelValueSourceTests.m
//  Alchemic
//
//  Created by Derek Clarkson on 14/07/2015.
//  Copyright © 2015 Derek Clarkson. All rights reserved.
//

@import XCTest;
#import <StoryTeller/StoryTeller.h>
#import <OCMock/OCMock.h>
#import <Alchemic/ALCContext.h>

#import "ALCModelValueSource.h"
#import "ALCDependencyPostProcessor.h"
#import "ALCContext+Internal.h"
#import "ALCInternalMacros.h"

@interface ALCModelValueSourceTests : XCTestCase

@end

@implementation ALCModelValueSourceTests

-(void) testResolveWithPostProcessors {
    
    STStartLogging(ALCHEMIC_LOG);
    id mockBuilder = OCMProtocolMock(@protocol(ALCBuilder));
    NSSet<id<ALCBuilder>> *builders = [NSSet setWithObject:mockBuilder];

    id mockContext = OCMClassMock([ALCContext class]);
    id mockAlchemic = OCMClassMock([ALCAlchemic class]);
    OCMStub(ClassMethod([mockAlchemic mainContext])).andReturn(mockContext);

    id<ALCModelSearchExpression> searchExpression = [ALCWithName withName:@"abc"];
    NSSet<id<ALCModelSearchExpression>> *searchExpressions = [NSSet setWithObject:searchExpression];

    id mockPostProcessor = OCMProtocolMock(@protocol(ALCDependencyPostProcessor));
    NSSet<id<ALCDependencyPostProcessor>> *postProcessors = [NSSet setWithObject:mockPostProcessor];

    OCMExpect([mockContext executeOnBuildersWithSearchExpressions:searchExpressions
                                   processingBuildersBlock:OCMOCK_ANY]).andDo(^(NSInvocation *inv){
        __unsafe_unretained ProcessBuilderBlock block = NULL;
        [inv getArgument:&block atIndex:3];
        block(builders);
    });
    OCMExpect([mockPostProcessor process:builders]).andReturn(builders);

    ALCModelValueSource *source = [[ALCModelValueSource alloc] initWithSearchExpressions:searchExpressions];
    [source resolveWithPostProcessors:postProcessors];

}


@end
