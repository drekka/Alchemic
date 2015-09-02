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

@interface MUObject : NSObject
@property (nonatomic, strong, readonly) NSString *aString;
-(instancetype) initWithString:(NSString *) aString;
@end

@implementation MUObject
-(instancetype) initWithString:(NSString *) aString {
    self = [super init];
    if (self) {
        _aString = aString;
    }
    return self;
}

@end

@interface MultiRegistrationsIntegrationTests : ALCTestCase
@end

@implementation MultiRegistrationsIntegrationTests {
    MUObject *_abc;
    MUObject *_def;
}

AcInject(_abc, AcName(@"abcObj"))
AcInject(_def, AcName(@"defObj"))

AcMethod(MUObject, muObjectWithString:, AcWithName(@"abcObj"), AcArg(NSString, AcValue(@"abc")))
AcMethod(MUObject, muObjectWithString:, AcWithName(@"defObj"), AcArg(NSString, AcValue(@"def")))

-(void) testMultiObjects {
    STStartLogging(@"LogAll");
    [super setupRealContext];
    [super startContextWithClasses:@[[MultiRegistrationsIntegrationTests class]]];
    AcInjectDependencies(self);
    XCTAssertNotNil(_abc);
    XCTAssertEqualObjects(@"abc", _abc.aString);
    XCTAssertNotNil(_def);
    XCTAssertEqualObjects(@"def", _def.aString);
}

-(MUObject *) muObjectWithString:(NSString *) aString {
    return [[MUObject alloc] initWithString:aString];
}

@end
