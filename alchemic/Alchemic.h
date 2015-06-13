//
//  alchemic.h
//  alchemic
//
//  Created by Derek Clarkson on 11/02/2015.
//  Copyright (c) 2015 Derek Clarkson. All rights reserved.
//

@import Foundation;

#import "ALCInternal.h"
#import "ALCClassBuilder.h"
#import "ALCContext.h"
#import "ALCClassMatcher.h"
#import "ALCProtocolMatcher.h"
#import "ALCNameMatcher.h"
#import "ALCLogger.h"
#import "ALCReturnType.h"
#import "ALCIsFactory.h"
#import "ALCMethodSelector.h"
#import "ALCIntoVariable.h"
#import "ALCAsName.h"
#import "ALCIsPrimary.h"

@import ObjectiveC;

#pragma mark - Defining objects

#define asName(_objectName) [ALCAsName asNameWithName:_objectName]

#define isFactory [[ALCIsFactory alloc] init]

#define primary [[ALCIsPrimary alloc] init]

#pragma mark - Dependency matching

#define withClass(_className) [ALCClassMatcher matcherWithClass:[_className class]]

#define withProtocol(_protocolName) [ALCProtocolMatcher matcherWithProtocol:@protocol(_protocolName)]

#define withName(_objectName) [ALCNameMatcher matcherWithName:_objectName]

#define returnType(_returnType) [ALCReturnType returnTypeWithClass:[_returnType class]]

#define createUsingSelector(_methodSelector) [ALCMethodSelector methodSelector:@selector(_methodSelector)]

#define intoVariable(_variableName) [ALCIntoVariable intoVariableWithName:_alchemic_toNSString(_variableName)]

#pragma mark - Injection

#define injectDependencies(object) [[Alchemic mainContext] injectDependencies:object]

#pragma mark - Registering

// All registration methods make use of the same signature.
#define register(...) \
+(void) _alchemic_concat(ALCHEMIC_METHOD_PREFIX, _registerClassBuilder):(ALCClassBuilder *) classBuilder { \
    [[Alchemic mainContext] registerClassBuilder:classBuilder, ## __VA_ARGS__, nil]; \
}

// Registers an injection point in the current class.
#define inject(...) \
+(void) _alchemic_concat(ALCHEMIC_METHOD_PREFIX, _registerDependencyInClassBuilder):(ALCClassBuilder *) classBuilder { \
    [[Alchemic mainContext] registerDependencyInClassBuilder:classBuilder, ## __VA_ARGS__, nil]; \
}

#pragma mark - The context itself

@interface Alchemic : NSObject

/**
 Returns the main context.
 
 @return An instance of ALCContext.
 */
+(ALCContext *) mainContext;

@end
