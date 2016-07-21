//
//  ALCMOdelSearchCriteriaTests.m
//  Alchemic
//
//  Created by Derek Clarkson on 21/7/16.
//  Copyright © 2016 Derek Clarkson. All rights reserved.
//

@import XCTest;
@import Alchemic;
@import Alchemic.Private;

@interface ALCMOdelSearchCriteriaTests : XCTestCase
@end

@implementation ALCMOdelSearchCriteriaTests {
    id<ALCObjectFactory> _factory;

}

-(void)setUp {
    _factory = [[ALCClassObjectFactory alloc] initWithClass:[NSString class]];
}

#pragma mark - Factories

-(void) testSearchCriteriaForClassSuccess {
    ALCModelSearchCriteria *criteria = [ALCModelSearchCriteria searchCriteriaForClass:[NSString class]];
    XCTAssertTrue([criteria acceptsObjectFactory:_factory name:@"abc"]);
    XCTAssertEqualObjects(@"class NSString", criteria.description);
}

-(void) testSearchCriteriaForClassFailure {
    ALCModelSearchCriteria *criteria = [ALCModelSearchCriteria searchCriteriaForClass:[NSDate class]];
    XCTAssertFalse([criteria acceptsObjectFactory:_factory name:@"abc"]);
}

-(void) testSearchCriteriaForProtocolSuccess {
    ALCModelSearchCriteria *criteria = [ALCModelSearchCriteria searchCriteriaForProtocol:@protocol(NSCopying)];
    XCTAssertTrue([criteria acceptsObjectFactory:_factory name:@"abc"]);
    XCTAssertEqualObjects(@"protocol NSCopying", criteria.description);
}

-(void) testSearchCriteriaForProtocolFailure {
    ALCModelSearchCriteria *criteria = [ALCModelSearchCriteria searchCriteriaForProtocol:@protocol(ALCObjectFactory)];
    XCTAssertFalse([criteria acceptsObjectFactory:_factory name:@"abc"]);
}

-(void) testSearchCriteriaForNameSuccess {
    ALCModelSearchCriteria *criteria = [ALCModelSearchCriteria searchCriteriaForName:@"abc"];
    XCTAssertTrue([criteria acceptsObjectFactory:_factory name:@"abc"]);
    XCTAssertEqualObjects(@"name 'abc'", criteria.description);
}

-(void) testSearchCriteriaForNameFailure {
    ALCModelSearchCriteria *criteria = [ALCModelSearchCriteria searchCriteriaForName:@"def"];
    XCTAssertFalse([criteria acceptsObjectFactory:_factory name:@"abc"]);
}

#pragma mark - Appending criteria

-(void) testAppendingProtocol {
    ALCModelSearchCriteria *criteria1 = [ALCModelSearchCriteria searchCriteriaForClass:[NSString class]];
    ALCModelSearchCriteria *criteria2 = [ALCModelSearchCriteria searchCriteriaForProtocol:@protocol(NSCopying)];
    [criteria1 appendSearchCriteria:criteria2];
    XCTAssertTrue([criteria1 acceptsObjectFactory:_factory name:@"abc"]);
    XCTAssertEqualObjects(@"class NSString and protocol NSCopying", criteria1.description);
}

-(void) testAppendingTwoProtocols {
    ALCModelSearchCriteria *criteria1 = [ALCModelSearchCriteria searchCriteriaForClass:[NSString class]];
    ALCModelSearchCriteria *criteria2 = [ALCModelSearchCriteria searchCriteriaForProtocol:@protocol(NSCopying)];
    ALCModelSearchCriteria *criteria3 = [ALCModelSearchCriteria searchCriteriaForProtocol:@protocol(NSSecureCoding)];
    [criteria1 appendSearchCriteria:criteria2];
    [criteria1 appendSearchCriteria:criteria3];
    XCTAssertTrue([criteria1 acceptsObjectFactory:_factory name:@"abc"]);
    XCTAssertEqualObjects(@"class NSString and protocol NSCopying and protocol NSSecureCoding", criteria1.description);
}

-(void) testAppendingThrowsWhenCombiningWithName {
    ALCModelSearchCriteria *criteria1 = [ALCModelSearchCriteria searchCriteriaForClass:[NSString class]];
    ALCModelSearchCriteria *criteria2 = [ALCModelSearchCriteria searchCriteriaForName:@"abc"];
    XCTAssertThrowsSpecific(([criteria1 appendSearchCriteria:criteria2]), AlchemicIllegalArgumentException);
}

@end
