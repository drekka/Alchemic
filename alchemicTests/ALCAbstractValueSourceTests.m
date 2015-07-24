//
//  ALCAbstractValueSourceTests.m
//  Alchemic
//
//  Created by Derek Clarkson on 24/07/2015.
//  Copyright © 2015 Derek Clarkson. All rights reserved.
//

@import XCTest;
#import "ALCAbstractValueSource.h"

@interface DummyValueSource : ALCAbstractValueSource
@property (nonatomic, strong) NSSet<id> *values;
@end

@implementation DummyValueSource
@end

@interface ALCAbstractValueSourceTests : XCTestCase

@end

@implementation ALCAbstractValueSourceTests {
	DummyValueSource *_source;
}

-(void) setUp {
	_source = [[DummyValueSource alloc] init];
}

-(void) testValueForTypeStringWhenSingleValue {
	_source.values = [NSSet setWithObject:@"abc"];
	id result = [_source valueForType:[NSString class]];
	XCTAssertTrue([result isKindOfClass:[NSString class]]);
	XCTAssertEqualObjects(@"abc", result);
}

@end
