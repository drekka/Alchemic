//
//  ClassIntegrationTests.m
//  Alchemic
//
//  Created by Derek Clarkson on 29/07/2015.
//  Copyright © 2015 Derek Clarkson. All rights reserved.
//

#import "ALCTestCase.h"
#import <Alchemic/Alchemic.h>
#import <StoryTeller/StoryTeller.h>

@interface MFWithArg : NSObject
@end

@implementation MFWithArg {
    int _counter;
}

AcRegister()
AcMethod(NSNumber, counter, AcWithName(@"abc"), AcFactory)
-(NSNumber *) counter {
    return @(++_counter);
}

AcMethod(NSNumber, createANumberFromANumber:, AcArg(NSNumber, AcName(@"abc")), AcWithName(@"def"), AcFactory)
-(NSNumber *) createANumberFromANumber:(NSNumber *) aNumber {
    return @(2 * [aNumber unsignedLongValue]);
}

@end

@interface MethodFactoryWithArgIntegrationTests : ALCTestCase
@end

@implementation MethodFactoryWithArgIntegrationTests {
    NSNumber *_aNumber1;
    NSNumber *_aNumber2;
    MFWithArg *_mfArg;
}

AcRegister(AcExternal)
AcInject(_aNumber1, AcName(@"def"))
AcInject(_aNumber2, AcName(@"def"))
AcInject(_mfArg)

-(void) testIntegrationCreatingASingletonWithAnArg {

    [self setupRealContext];

    STStartLogging(@"[MethodFactoryWithArgIntegrationTests]");
    [self startContextWithClasses:@[[MFWithArg class], [MethodFactoryWithArgIntegrationTests class]]];

    AcInjectDependencies(self);

    NSArray<NSNumber *> *checkResults = @[@2, @4];
    XCTAssertTrue([checkResults containsObject:_aNumber1]);
    XCTAssertTrue([checkResults containsObject:_aNumber2]);
    XCTAssertNotEqual(_aNumber1, _aNumber2);
}

@end
