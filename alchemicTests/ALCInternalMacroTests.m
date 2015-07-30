//
//  ALCInternalMacroTests.m
//  Alchemic
//
//  Created by Derek Clarkson on 23/07/2015.
//  Copyright © 2015 Derek Clarkson. All rights reserved.
//

#import <XCTest/XCTest.h>
#import <OCMock/OCMock.h>
#import "ALCInternalMacros.h"
#import "ALCName.h"
#import "ALCMacroProcessor.h"

@interface ALCInternalMacroTests : XCTestCase

@end

@implementation ALCInternalMacroTests

-(void) test_alc_concat {
	int alc_concat(abc, def) = 5;
	XCTAssertEqual(5, abcdef);
}

-(void) test_alc_toCharPointer {
	NSString *x = [NSString stringWithUTF8String:alc_toCharPointer(abc)];
	XCTAssertEqualObjects(@"abc", x);
}

-(void) test_alc_toNSString {
	NSString *x = alc_toNSString(abc);
	XCTAssertEqualObjects(@"abc", x);
}

-(void) test_alc_processVarArgsIncluding {
	NSString *result = [self methodWithVarArgsIncluding:@"abc", @"def", nil];
	XCTAssertEqualObjects(@"abcdef", result);
}

-(void) test_alc_processVarArgsIncludingWhenNoArgs {
	NSString *result = [self methodWithVarArgsIncluding:nil];
	XCTAssertEqualObjects(@"", result);
}

-(void) test_alc_loadMacrosAfter {
	id mockMacroProcessor = OCMClassMock([ALCMacroProcessor class]);
	OCMExpect([mockMacroProcessor addMacro:[OCMArg checkWithBlock:^BOOL(id value){
		return [value isKindOfClass:[ALCName class]]
		&& [((ALCName *) value).aName isEqualToString:@"def"];
	}]]);
	[self macroProcessorWithVarArgsAfter:mockMacroProcessor macros:[ALCName withName:@"abc"], [ALCName withName:@"def"], nil];
}

-(void) test_alc_loadMacrosIncluding {
	id mockMacroProcessor = OCMClassMock([ALCMacroProcessor class]);
	OCMExpect([mockMacroProcessor addMacro:[OCMArg checkWithBlock:^BOOL(id value){
		return [value isKindOfClass:[ALCName class]]
		&& [((ALCName *) value).aName isEqualToString:@"abc"];
	}]]);
	OCMExpect([mockMacroProcessor addMacro:[OCMArg checkWithBlock:^BOOL(id value){
		return [value isKindOfClass:[ALCName class]]
		&& [((ALCName *) value).aName isEqualToString:@"def"];
	}]]);
	[self macroProcessorWithVarArgsIncluding:mockMacroProcessor macros:[ALCName withName:@"abc"], [ALCName withName:@"def"], nil];
}

#pragma mark - Internal

-(NSString *) methodWithVarArgsIncluding:(NSString *) first, ... {
	NSMutableString *result = [[NSMutableString alloc] init];
	alc_processVarArgsIncluding(NSString *, first, ^(NSString *arg){[result appendString:arg];});
	return result;
}

-(void) macroProcessorWithVarArgsAfter:(ALCMacroProcessor *) macroProcessor macros:(id) firstArg, ... NS_REQUIRES_NIL_TERMINATION {
	alc_loadMacrosAfter(macroProcessor, firstArg);
}

-(void) macroProcessorWithVarArgsIncluding:(ALCMacroProcessor *) macroProcessor macros:(id) firstArg, ... NS_REQUIRES_NIL_TERMINATION {
	alc_loadMacrosAfter(macroProcessor, firstArg);
}


@end
