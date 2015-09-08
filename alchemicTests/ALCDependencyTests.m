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
#import "ALCValueSource.h"
#import "ALCTestCase.h"
#import "ALCConstantValueSource.h"

@interface ALCDependencyTests : ALCTestCase

@end

@implementation ALCDependencyTests {
    id _mockValueSource;
    ALCDependency *_dependency;
}

-(void) setUp {
    _mockValueSource = OCMProtocolMock(@protocol(ALCValueSource));
    _dependency = [[ALCDependency alloc] initWithValueSource:_mockValueSource];
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

-(void) testDescription {
    ALCConstantValueSource *valueSource = [[ALCConstantValueSource alloc] initWithType:[NSNumber class] value:@5];
    ALCDependency *dependency = [[ALCDependency alloc] initWithValueSource:valueSource];
    XCTAssertEqualObjects(@"[NSNumber]<NSSecureCoding><NSCopying> -> Constant: 5", [dependency description]);
}

@end
