//
//  ALCAbstractValueSourceTests.m
//  Alchemic
//
//  Created by Derek Clarkson on 2/9/16.
//  Copyright © 2016 Derek Clarkson. All rights reserved.
//

@import XCTest;
@import Alchemic;
@import Alchemic.Private;
@import OCMock;

@interface ALCAbstractValueSourceTests : XCTestCase
@end

@implementation ALCAbstractValueSourceTests {
    ALCAbstractValueSource *_source;
}

-(void)setUp {
    _source = [[ALCAbstractValueSource alloc] initWithType:[ALCType typeWithClass:[NSString class]]];
}

-(void) testInitWithType {
    ALCType *type = _source.type;
    XCTAssertEqual([NSString class], type.objcClass);
}

-(void) testValueWithError {
    XCTAssertThrows([_source valueWithError:NULL]);
}

-(void) testReferencesObjectFactory {
    id mockFactory = OCMProtocolMock(@protocol(ALCObjectFactory));
    XCTAssertFalse([_source referencesObjectFactory:mockFactory]);
}

-(void) testResolveWithStackModel {
    id mockModel = OCMProtocolMock(@protocol(ALCModel));
    [_source resolveWithStack:[NSMutableArray array] model:mockModel];
    // Nothing to test.
}

-(void) testIsReady {
    XCTAssertTrue(_source.isReady);
}

-(void) testResolvingDescription {
    XCTAssertEqualObjects(@"class NSString *", _source.resolvingDescription);
}

@end
