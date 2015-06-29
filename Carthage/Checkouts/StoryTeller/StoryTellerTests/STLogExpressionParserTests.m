//
//  STLogExpressionParserTests.m
//  StoryTeller
//
//  Created by Derek Clarkson on 24/06/2015.
//  Copyright © 2015 Derek Clarkson. All rights reserved.
//

#import <XCTest/XCTest.h>
#import <PEGKit/PEGKit.h>

#import "STLogExpressionParser.h"
#import "STLogExpressionParserDelegate.h"

typedef NS_ENUM(NSUInteger, Callback) {
    CallbackClass = 1,
    CallbackProtocol,
    CallbackBoolean,
    CallbackString,
    CallbackNumber,
    CallbackNil,
    CallbackKeypath,
    CallbackLogicalExpr,
    CallbackMathExpr,
    CallbackSingleKey,
    CallbackIsa,
    CallbackLogAll,
    CallbackLogRoots
};


@interface STLogExpressionParserTests : XCTestCase<STLogExpressionParserDelegate>

@end

@implementation STLogExpressionParserTests {
    NSArray<PKToken *> *_matchedTokens;
    NSArray<NSNumber *> * _callbacksMade;
}

-(void) setUp {
    _matchedTokens = @[];
    _callbacksMade = @[];
}


#pragma mark - Delegate methods

-(void) parser:(PKParser * __nonnull)parser didMatchSingleKey:(PKAssembly * __nonnull)assembly {
    _callbacksMade = [_callbacksMade arrayByAddingObject:@(CallbackSingleKey)];
}

-(void) parser:(PKParser * __nonnull)parser didMatchMathExpression:(PKAssembly * __nonnull)assembly {
    NSLog(@"Matched math expression");
    _callbacksMade = [_callbacksMade arrayByAddingObject:@(CallbackMathExpr)];
    PKToken *op = [parser popToken];
    _matchedTokens = [_matchedTokens arrayByAddingObject:op];
}

-(void) parser:(PKParser * __nonnull)parser didMatchLogicalExpression:(PKAssembly * __nonnull)assembly {
    NSLog(@"Matched logical expression");
    _callbacksMade = [_callbacksMade arrayByAddingObject:@(CallbackLogicalExpr)];
    PKToken *op = [parser popToken];
    _matchedTokens = [_matchedTokens arrayByAddingObject:op];
}

-(void) parser:(PKParser __nonnull *) parser didMatchLogAll:(PKAssembly __nonnull *) assembly {
    PKToken *token = [parser popToken];
    NSLog(@"Matched LogAll: %@", token.value);
    _callbacksMade = [_callbacksMade arrayByAddingObject:@(CallbackLogAll)];
    _matchedTokens = [_matchedTokens arrayByAddingObject:token];
}

-(void) parser:(PKParser __nonnull *) parser didMatchLogRoot:(PKAssembly __nonnull *) assembly {
    PKToken *token = [parser popToken];
    NSLog(@"Matched LogRoot: %@", token.value);
    _callbacksMade = [_callbacksMade arrayByAddingObject:@(CallbackLogRoots)];
    _matchedTokens = [_matchedTokens arrayByAddingObject:token];
}

-(void) parser:(PKParser __nonnull *) parser didMatchIsa:(PKAssembly __nonnull *) assembly {
    [parser popToken];
    _callbacksMade = [_callbacksMade arrayByAddingObject:@(CallbackIsa)];
}

-(void) parser:(PKParser * __nonnull) parser didMatchClass:(PKAssembly * __nonnull) assembly {
    PKToken *token = [parser popToken];
    NSLog(@"Matched class: %@", token.value);
    _callbacksMade = [_callbacksMade arrayByAddingObject:@(CallbackClass)];
    _matchedTokens = [_matchedTokens arrayByAddingObject:token];
}

-(void) parser:(PKParser * __nonnull) parser didMatchProtocol:(PKAssembly * __nonnull) assembly {
    PKToken *token = [parser popToken];
    NSLog(@"Matched protocol: %@", token.value);
    _callbacksMade = [_callbacksMade arrayByAddingObject:@(CallbackProtocol)];
    _matchedTokens = [_matchedTokens arrayByAddingObject:token];
}

-(void) parser:(PKParser * __nonnull) parser didMatchBoolean:(PKAssembly * __nonnull) assembly {
    PKToken *token = [parser popToken];
    NSLog(@"Matched boolean: %@", token.value);
    _callbacksMade = [_callbacksMade arrayByAddingObject:@(CallbackBoolean)];
    _matchedTokens = [_matchedTokens arrayByAddingObject:token];
}

-(void) parser:(PKParser * __nonnull) parser didMatchString:(PKAssembly * __nonnull) assembly {
    PKToken *token = [parser popToken];
    NSLog(@"Matched string: %@", token.value);
    _callbacksMade = [_callbacksMade arrayByAddingObject:@(CallbackString)];
    _matchedTokens = [_matchedTokens arrayByAddingObject:token];
}
-(void) parser:(PKParser * __nonnull) parser didMatchNumber:(PKAssembly * __nonnull) assembly {
    PKToken *token = [parser popToken];
    NSLog(@"Matched number: %@", token.value);
    _callbacksMade = [_callbacksMade arrayByAddingObject:@(CallbackNumber)];
    _matchedTokens = [_matchedTokens arrayByAddingObject:token];
}
-(void) parser:(PKParser * __nonnull) parser didMatchNil:(PKAssembly * __nonnull) assembly {
    PKToken *token = [parser popToken];
    NSLog(@"Matched nil: %@", token.value);
    _callbacksMade = [_callbacksMade arrayByAddingObject:@(CallbackNil)];
    _matchedTokens = [_matchedTokens arrayByAddingObject:token];
}

-(void) parser:(PKParser __nonnull *) parser didMatchKeyPath:(PKAssembly __nonnull *) assembly {
    NSLog(@"Matched key path ...");
    _callbacksMade = [_callbacksMade arrayByAddingObject:@(CallbackKeypath)];
    while (! [assembly isStackEmpty]) {
        PKToken *token = [parser popToken];
        NSLog(@"\tpath: %@", token.value);
        _matchedTokens = [_matchedTokens arrayByAddingObject:token];
    }
}

#pragma mark - Options

-(void) testLogAll {
    [self parse:@"LogAll"];
    [self validateMatchedDelegateCalls:@[@(CallbackLogAll)]];
    [self validateMatchedTokens:@[@(STLOGEXPRESSIONPARSER_TOKEN_KIND_LOGALL)]];
}

-(void) testLogRoots {
    [self parse:@"LogRoots"];
    [self validateMatchedDelegateCalls:@[@(CallbackLogRoots)]];
    [self validateMatchedTokens:@[@(STLOGEXPRESSIONPARSER_TOKEN_KIND_LOGROOT)]];
}

#pragma mark - Values

-(void) testSingleValueString {
    [self parse:@"\"abc\""];
    [self validateMatchedDelegateCalls:@[@(CallbackString), @(CallbackSingleKey)]];
    [self validateMatchedTokens:@[@(TOKEN_KIND_BUILTIN_QUOTEDSTRING)]];
    XCTAssertEqualObjects(@"abc", _matchedTokens[0].quotedStringValue);
}

-(void) testSingleValueQuotedString {
    [self parse:@"abc"];
    [self validateMatchedDelegateCalls:@[@(CallbackString), @(CallbackSingleKey)]];
    [self validateMatchedTokens:@[@(TOKEN_KIND_BUILTIN_WORD)]];
    XCTAssertEqualObjects(@"abc", _matchedTokens[0].quotedStringValue);
}

-(void) testSingleValueNumber {
    [self parse:@"1.23"];
    [self validateMatchedDelegateCalls:@[@(CallbackNumber), @(CallbackSingleKey)]];
    [self validateMatchedTokens:@[@(TOKEN_KIND_BUILTIN_NUMBER)]];
    XCTAssertEqualObjects(@(1.23), _matchedTokens[0].value);
}

-(void) testClass {
    [self parse:@"[Abc]"];
    [self validateMatchedDelegateCalls:@[@(CallbackClass)]];
    [self validateMatchedTokens:@[@(TOKEN_KIND_BUILTIN_WORD)]];
    XCTAssertEqualObjects(@"Abc", _matchedTokens[0].value);
}

-(void) testProtocol {
    [self parse:@"<Abc>"];
    [self validateMatchedDelegateCalls:@[@(CallbackProtocol)]];
    [self validateMatchedTokens:@[@(TOKEN_KIND_BUILTIN_WORD)]];
    XCTAssertEqualObjects(@"Abc", _matchedTokens[0].value);
}

-(void) testClassPropertyEqualsString {

    [self parse:@"[Abc].userId == \"Derekc\""];

    [self validateMatchedDelegateCalls:@[
                                         @(CallbackClass),
                                         @(CallbackKeypath),
                                         @(CallbackString),
                                         @(CallbackLogicalExpr)
                                         ]];
    [self validateMatchedTokens:@[
                                  @(TOKEN_KIND_BUILTIN_WORD),
                                  @(TOKEN_KIND_BUILTIN_WORD),
                                  @(TOKEN_KIND_BUILTIN_QUOTEDSTRING),
                                  @(STLOGEXPRESSIONPARSER_TOKEN_KIND_EQ)
                                  ]];
    XCTAssertEqualObjects(@"Abc", _matchedTokens[0].quotedStringValue);
    XCTAssertEqualObjects(@"userId", _matchedTokens[1].value);
    XCTAssertEqualObjects(@"Derekc", _matchedTokens[2].quotedStringValue);
    XCTAssertEqualObjects(@"==", _matchedTokens[3].value);
}

-(void) testClassPropertyEqualsNi; {

    [self parse:@"[Abc].userId == nil"];

    [self validateMatchedDelegateCalls:@[
                                         @(CallbackClass),
                                         @(CallbackKeypath),
                                         @(CallbackNil),
                                         @(CallbackLogicalExpr)
                                         ]];
    [self validateMatchedTokens:@[
                                  @(TOKEN_KIND_BUILTIN_WORD),
                                  @(TOKEN_KIND_BUILTIN_WORD),
                                  @(STLOGEXPRESSIONPARSER_TOKEN_KIND_NIL),
                                  @(STLOGEXPRESSIONPARSER_TOKEN_KIND_EQ)
                                  ]];
    XCTAssertEqualObjects(@"Abc", _matchedTokens[0].quotedStringValue);
    XCTAssertEqualObjects(@"userId", _matchedTokens[1].value);
    XCTAssertEqualObjects(@"nil", _matchedTokens[2].quotedStringValue);
    XCTAssertEqualObjects(@"==", _matchedTokens[3].value);
}

-(void) testClassKeyPathEqualsString {
    [self parse:@"[Abc].user.supervisor.name == \"Derekc\""];

    [self validateMatchedDelegateCalls:@[
                                         @(CallbackClass),
                                         @(CallbackKeypath),
                                         @(CallbackString),
                                         @(CallbackLogicalExpr)
                                         ]];
    [self validateMatchedTokens:@[
                                  @(TOKEN_KIND_BUILTIN_WORD),
                                  @(TOKEN_KIND_BUILTIN_WORD),
                                  @(TOKEN_KIND_BUILTIN_WORD),
                                  @(TOKEN_KIND_BUILTIN_WORD),
                                  @(TOKEN_KIND_BUILTIN_QUOTEDSTRING),
                                  @(STLOGEXPRESSIONPARSER_TOKEN_KIND_EQ)
                                  ]];
    XCTAssertEqualObjects(@"Abc", _matchedTokens[0].quotedStringValue);
    XCTAssertEqualObjects(@"name", _matchedTokens[1].value);
    XCTAssertEqualObjects(@"supervisor", _matchedTokens[2].value);
    XCTAssertEqualObjects(@"user", _matchedTokens[3].value);
    XCTAssertEqualObjects(@"Derekc", _matchedTokens[4].quotedStringValue);
    XCTAssertEqualObjects(@"==", _matchedTokens[5].value);
}

-(void) testIsaClass {
    [self parse:@"isa [Abc]"];
    [self validateMatchedDelegateCalls:@[
                                         @(CallbackIsa),
                                         @(CallbackClass)
                                         ]];
    [self validateMatchedTokens:@[
                                  @(TOKEN_KIND_BUILTIN_WORD)
                                  ]];
    XCTAssertEqualObjects(@"Abc", _matchedTokens[0].value);
}

-(void) testIsaProtocol {
    [self parse:@"isa <Abc>"];
    [self validateMatchedDelegateCalls:@[
                                         @(CallbackIsa),
                                         @(CallbackProtocol)
                                         ]];
    [self validateMatchedTokens:@[
                                  @(TOKEN_KIND_BUILTIN_WORD)
                                  ]];
    XCTAssertEqualObjects(@"Abc", _matchedTokens[0].value);
}

#pragma mark - Errors

-(void) testInvalidSingleValueBooleanTrue {
    [self parse:@"true" withCode:1 error:@"Failed to match next input token"];
}

-(void) testInvalidSingleValueBooleanYes {
    [self parse:@"YES" withCode:1 error:@"Failed to match next input token"];
}

-(void) testInvalidSingleValueBooleanFalse {
    [self parse:@"false" withCode:1 error:@"Failed to match next input token"];
}

-(void) testInvalidSingleValueBooleanNo {
    [self parse:@"NO" withCode:1 error:@"Failed to match next input token"];
}

-(void) testMissingValue {
    [self parse:@"[Abc].userId =" withCode:1 error:@"Failed to match next input token"];
}

-(void) testMissingClass {
    [self parse:@".userId = abc" withCode:1 error:@"Failed to match next input token"];
}

-(void) testMissingPath {
    [self parse:@"<Abc> = abc" withCode:1 error:@"Failed to match next input token"];
}

-(void) testMissingOp {
    [self parse:@"<Abc>.userId abc" withCode:1 error:@"Failed to match next input token"];
}

-(void) testInvalidOp1 {
    [self parse:@"<Abc>.userId >=< abc" withCode:1 error:@"Failed to match next input token"];
}

-(void) testInvalidOp2 {
    [self parse:@"[Abc].userId >=< abc" withCode:1 error:@"Failed to match next input token"];
}

-(void) testIllegalSyntaxOptionAndCriteria {
    [self parse:@"LogAll [Abc].userId == abc" withCode:1 error:@"Failed to match next input token"];
}

#pragma mark - Internal

-(void) validateMatchedDelegateCalls:(NSArray<NSNumber *> *) expected {
    XCTAssertEqual([expected count], [_callbacksMade count]);
    [expected enumerateObjectsUsingBlock:^(NSNumber *  __nonnull expectedCallback, NSUInteger idx, BOOL * __nonnull stop) {
        NSInteger expectedCallbackType = [expectedCallback integerValue];
        NSInteger matchedCallbackType = self->_callbacksMade[idx].integerValue;
        XCTAssertEqual(expectedCallbackType, matchedCallbackType);
    }];
}

-(void) validateMatchedTokens:(NSArray<NSNumber *> *) expected {
    XCTAssertEqual([expected count], [_matchedTokens count]);
    [expected enumerateObjectsUsingBlock:^(NSNumber *  __nonnull expectedTokenKind, NSUInteger idx, BOOL * __nonnull stop) {
        NSInteger expectedToken = [expectedTokenKind integerValue];
        NSInteger matchedToken = self->_matchedTokens[idx].tokenKind;
        XCTAssertEqual(expectedToken, matchedToken);
    }];

}

-(void) parse:(NSString __nonnull *) string {

    STLogExpressionParser *parser = [[STLogExpressionParser alloc] initWithDelegate:self];
    //parser.enableVerboseErrorReporting = YES;
    NSError *localError = nil;
    PKAssembly __nonnull *result = [parser parseString:string error:&localError];

    XCTAssertNil(localError);
    XCTAssertNotNil(result.stack);
    NSArray __nonnull *results = result.stack;
    XCTAssertEqual(0u, [results count]);
}

-(void) parse:(NSString __nonnull *) string withCode:(NSInteger) code error:(NSString *) errorMessage {
    NSError *localError = nil;
    STLogExpressionParser *parser = [[STLogExpressionParser alloc] initWithDelegate:self];
    parser.enableVerboseErrorReporting = YES;
    PKAssembly __nonnull *result = [parser parseString:string error:&localError];
    XCTAssertNotNil(localError);
    XCTAssertNil(result);
    XCTAssertEqualObjects(errorMessage, localError.localizedDescription);
    XCTAssertEqual(code, localError.code);
}

@end
