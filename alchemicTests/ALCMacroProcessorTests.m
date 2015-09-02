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
                  + ALCAllowedMacrosFactory
                  + ALCAllowedMacrosExternal
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

-(void) testAddMacroExternal {
    [_processor addMacro:AcExternal];
    XCTAssertTrue(_processor.isExternal);
}

-(void) testAddMacroName {
    [_processor addMacro:AcWithName(@"abc")];
    XCTAssertEqualObjects(@"abc", _processor.asName);
}

-(void) testAddMacroArg {
    ALCArg *arg = AcArg(NSString, AcName(@"abc"));
    [_processor addMacro:arg];
    ALCModelValueSource *valueSource = [_processor valueSourceAtIndex:0 whenAvailable:NULL];
    XCTAssertEqualObjects(AcName(@"abc"), [valueSource.searchExpressions anyObject]);
}

-(void) testAddMacroArgsAndValueSourceAtIndex {

    ALCArg *arg1 = AcArg(NSString, AcName(@"abc"));
    ALCArg *arg2 = AcArg(NSString, AcName(@"def"));

    [_processor addMacro:arg1];
    [_processor addMacro:arg2];

    ALCModelValueSource *source1 = [_processor valueSourceAtIndex:0 whenAvailable:NULL];
    ALCModelValueSource *source2 = [_processor valueSourceAtIndex:1 whenAvailable:NULL];

    XCTAssertEqualObjects(AcName(@"abc"), [source1.searchExpressions anyObject]);
    XCTAssertEqualObjects(AcName(@"def"), [source2.searchExpressions anyObject]);
    XCTAssertEqual(2u, [_processor valueSourceCount]);
}

-(void) testAddMacroInvalidMacro {
    ALCMacroProcessor *processor = [[ALCMacroProcessor alloc] initWithAllowedMacros:0];
    XCTAssertThrowsSpecificNamed([processor addMacro:[[ALCIsFactory alloc] init]], NSException, @"AlchemicUnexpectedMacro");
}

-(void) testDescription {

    [_processor addMacro:AcFactory];
    [_processor addMacro:AcPrimary];
    [_processor addMacro:AcExternal];
    [_processor addMacro:AcWithName(@"name")];
    [_processor addMacro:AcArg(NSString, AcName(@"abc"))];
    [_processor addMacro:AcArg(NSNumber, AcValue(@12))];

    XCTAssertEqualObjects(@"Macro processor: factory, primary, external, name: 'name', AcArg(NSString, 'abc'), AcArg(NSNumber, AcValue:12)", [_processor description]);
}

@end
