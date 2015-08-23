//
//  ALCAbstractMacroProcessorTests.m
//  Alchemic
//
//  Created by Derek Clarkson on 24/07/2015.
//  Copyright © 2015 Derek Clarkson. All rights reserved.
//

@import XCTest;

#import "ALCMacros.h"
#import "ALCMacroProcessor.h"
#import "ALCValueSourceFactory.h"
#import "ALCArg.h"
#import "ALCName.h"
#import "ALCClass.h"
#import "ALCProtocol.h"
#import "ALCConstantValue.h"
#import "ALCValueSource.h"
#import "ALCIsFactory.h"
#import "ALCModelValueSource.h"

@interface ALCMacroProcessorTests : XCTestCase

@end

@implementation ALCMacroProcessorTests {
    ALCMacroProcessor *_processor;
}

-(void) setUp {
    _processor = [[ALCMacroProcessor alloc] initWithAllowedMacros:
                  ALCAllowedMacrosArg
                  + ALCAllowedMacrosModelSearch
                  + ALCAllowedMacrosValue
                  + ALCAllowedMacrosFactory
                  + ALCAllowedMacrosName
                  + ALCAllowedMacrosPrimary];
}

-(void) testAddMacroFactory {
    [_processor addMacro:AcFactory];
    XCTAssertTrue(_processor.isFactory);
}

-(void) testAddMacroPrimary {
    [_processor addMacro:AcPrimary];
    XCTAssertTrue(_processor.isPrimary);
}

-(void) testAddMacroName {
    [_processor addMacro:AcWithName(@"abc")];
    XCTAssertEqualObjects(@"abc", _processor.asName);
}

-(void) testAddMacroArg {
    ALCArg *arg = AcArg(NSString, AcName(@"abc"));
    [_processor addMacro:arg];
    ALCModelValueSource *valueSource = [_processor valueSourceAtIndex:0];
    XCTAssertEqualObjects(AcName(@"abc"), [valueSource.searchExpressions anyObject]);
}

-(void) testAddMacroArgs {

    ALCArg *arg1 = AcArg(NSString, AcName(@"abc"));
    ALCArg *arg2 = AcArg(NSString, AcName(@"def"));

    [_processor addMacro:arg1];
    [_processor addMacro:arg2];

    ALCModelValueSource *source1 = [_processor valueSourceAtIndex:0];
    ALCModelValueSource *source2 = [_processor valueSourceAtIndex:1];

    XCTAssertEqualObjects(AcName(@"abc"), [source1.searchExpressions anyObject]);
    XCTAssertEqualObjects(AcName(@"def"), [source2.searchExpressions anyObject]);
    XCTAssertEqual(2u, [_processor valueSourceCount]);
}

-(void) testAddMacroFirstExpression {

    ALCConstantValue *value = AcValue(@5);

    [_processor addMacro:value];

    id<ALCValueSource> valueSource = [_processor valueSourceAtIndex:0];
    [valueSource resolveWithPostProcessors:[NSSet set] dependencyStack:[NSMutableArray array]];
    XCTAssertEqualObjects(@5, valueSource.value);

}

-(void) testAddMacroCombinesExpressions {

    ALCClass *classMacro = AcClass(NSString);
    ALCProtocol *protocolMacro = AcProtocol(NSCopying);

    [_processor addMacro:classMacro];
    [_processor addMacro:protocolMacro];

    ALCModelValueSource *valueSource = [_processor valueSourceAtIndex:0];
    XCTAssertTrue([valueSource.searchExpressions containsObject:classMacro]);
    XCTAssertTrue([valueSource.searchExpressions containsObject:protocolMacro]);
}

-(void) testAddMacroInvalidMacro {
    ALCMacroProcessor *processor = [[ALCMacroProcessor alloc] initWithAllowedMacros:0];
    XCTAssertThrowsSpecificNamed([processor addMacro:[[ALCIsFactory alloc] init]], NSException, @"AlchemicUnexpectedMacro");
}


@end
