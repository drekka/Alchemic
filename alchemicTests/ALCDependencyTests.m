//
//  ALCDependencyTests.m
//  Alchemic
//
//  Created by Derek Clarkson on 29/07/2015.
//  Copyright © 2015 Derek Clarkson. All rights reserved.
//

#import "ALCTestCase.h"
#import <OCMock/OCMock.h>
#import <Alchemic/Alchemic.h>

#import "ALCDependency.h"
#import "ALCDependencyPostProcessor.h"
#import "ALCValueSource.h"
#import "ALCConstantValueSource.h"
#import "ALCClassBuilder.h"
#import "ALCModelValueSource.h"

@interface ALCDependencyTests : ALCTestCase

@end

@implementation ALCDependencyTests {
    id _mockValueSource;
    ALCDependency *_dependency;
}

-(void) setUp {
    _mockValueSource = OCMClassMock([ALCModelValueSource class]); // Cannot use the protocol here due to the KVO watches.
    _dependency = [[ALCDependency alloc] initWithValueSource:_mockValueSource];
}

-(void) testResolveForwardsToValueSource {
	NSSet<id<ALCDependencyPostProcessor>> *postProcessors = [NSSet set];
    NSMutableArray *stack = [NSMutableArray array];
	[_dependency resolveWithPostProcessors:postProcessors dependencyStack:stack];
	OCMVerify([_mockValueSource resolveWithPostProcessors:postProcessors dependencyStack:stack]);
}

-(void) testGetsValueFromValueSource {
	OCMExpect([(id<ALCValueSource>)_mockValueSource value]).andReturn(@"abc");
	id value = _dependency.value;
	XCTAssertEqualObjects(@"abc", value);
	OCMVerifyAll(_mockValueSource);
}

-(void) testGetsValueClassFromValueSource {
    OCMExpect([(id<ALCValueSource>)_mockValueSource valueClass]).andReturn([NSString class]);
    Class valueClass = _dependency.valueClass;
    XCTAssertEqualObjects([NSString class], valueClass);
    OCMVerifyAll(_mockValueSource);
}

-(void) testDependencyStateTracksConstantValueSourceState {

    ALCConstantValueSource *valueSource = [[ALCConstantValueSource alloc] initWithType:[NSString class] value:@"abc"];
    ALCDependency *dependency = [[ALCDependency alloc] initWithValueSource:valueSource];
    XCTAssertFalse(valueSource.available);
    XCTAssertFalse(dependency.available);

    [dependency resolveWithPostProcessors:[NSSet set] dependencyStack:[NSMutableArray array]];
    XCTAssertTrue(valueSource.available);
    XCTAssertTrue(dependency.available);

}

-(void) testDependencyStateTracksModelValueSourceState {

    [self setupMockContext];

    ALCClassBuilder *classBuilder = [[ALCClassBuilder alloc] initWithValueClass:[NSString class]];
    classBuilder.external = YES;

    NSSet *searchExpressions = [NSSet setWithObject:AcClass(NSString)];
    OCMStub([self.mockContext executeOnBuildersWithSearchExpressions:searchExpressions processingBuildersBlock:OCMOCK_ANY]).andDo(^(NSInvocation *inv){
        __unsafe_unretained ProcessBuilderBlock processBuilderBlock;
        [inv getArgument:&processBuilderBlock atIndex:3];
        processBuilderBlock([NSSet setWithObject:classBuilder]);
    });

    ALCModelValueSource *valueSource = [[ALCModelValueSource alloc] initWithType:[NSString class]
                                                               searchExpressions:searchExpressions];
    
    ALCDependency *dependency = [[ALCDependency alloc] initWithValueSource:valueSource];
    XCTAssertFalse(valueSource.available);
    XCTAssertFalse(dependency.available);

    [dependency resolveWithPostProcessors:[NSSet set] dependencyStack:[NSMutableArray array]];
    XCTAssertFalse(valueSource.available);
    XCTAssertFalse(dependency.available);

    classBuilder.value = @"abc";
    XCTAssertTrue(valueSource.available);
    XCTAssertTrue(classBuilder.available);

}

-(void) testDescription {
    ALCConstantValueSource *valueSource = [[ALCConstantValueSource alloc] initWithType:[NSNumber class] value:@5];
	ALCDependency *dependency = [[ALCDependency alloc] initWithValueSource:valueSource];
	XCTAssertEqualObjects(@"[NSNumber]<NSSecureCoding><NSCopying> -> Constant: 5", [dependency description]);
}

@end
