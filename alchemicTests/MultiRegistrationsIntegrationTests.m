//
//  MultiRegistrationsIntegrationTests.m
//  alchemic
//
//  Created by Derek Clarkson on 18/08/2015.
//  Copyright © 2015 Derek Clarkson. All rights reserved.
//

#import "ALCTestCase.h"
#import <StoryTeller/StoryTeller.h>
#import <Alchemic/Alchemic.h>

@interface MultiRegistrationsIntegrationTests : ALCTestCase
@end

@implementation MultiRegistrationsIntegrationTests {
    NSNumber *_abc;
    NSNumber *_def;
}

AcRegister(AcExternal, AcWithName(@"self"))

AcInject(_abc, AcName(@"abcObj"))
AcInject(_def, AcName(@"defObj"))

AcMethod(NSNumber, muObjectWithNumber:, AcWithName(@"abcObj"), AcArg(NSNumber, AcValue(@1)))
AcMethod(NSNumber, muObjectWithNumber:, AcWithName(@"defObj"), AcArg(NSNumber, AcValue(@2)))

-(void) testIntegrationMultiObjects {

    [super setupRealContext];

    [super startContextWithClasses:@[[MultiRegistrationsIntegrationTests class]]];

    AcSet(self, AcName(@"self"));
    AcInjectDependencies(self);

    XCTAssertNotNil(_abc);
    XCTAssertEqualObjects(@2, _abc);
    XCTAssertNotNil(_def);
    XCTAssertEqualObjects(@4, _def);
}

-(NSNumber *) muObjectWithNumber:(NSNumber *) number {
    return [NSNumber numberWithInt:[number intValue] * 2];
}

@end
