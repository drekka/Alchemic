//
//  ALCMacros.h
//  alchemic
//
//  Created by Derek Clarkson on 23/06/2015.
//  Copyright © 2015 Derek Clarkson. All rights reserved.
//

#pragma mark - Defining objects

#define asName(_objectName) [ALCAsName asNameWithName:_objectName]

#define isFactory [[ALCIsFactory alloc] init]

#define isPrimary [[ALCIsPrimary alloc] init]

#pragma mark - Dependency matching

#define withClass(_className) [ALCClassMatcher matcherWithClass:[_className class]]

#define withProtocol(_protocolName) [ALCProtocolMatcher matcherWithProtocol:@protocol(_protocolName)]

#define withName(_objectName) [ALCNameMatcher matcherWithName:_objectName]

#define returnType(_returnType) [ALCReturnType returnTypeWithClass:[_returnType class]]

#define createUsingSelector(_methodSelector) [ALCMethodSelector methodSelector:@selector(_methodSelector)]

#define intoVariable(_variableName) [ALCIntoVariable intoVariableWithName:_alchemic_toNSString(_variableName)]

#pragma mark - Injection

#define injectDependencies(object) [[ALCAlchemic mainContext] injectDependencies:object]

#pragma mark - Registering

// All registration methods make use of the same signature.
#define register(...) \
+(void) _alchemic_concat(ALCHEMIC_METHOD_PREFIX, _registerClassBuilder):(ALCClassBuilder *) classBuilder { \
[[ALCAlchemic mainContext] registerClassBuilder:classBuilder, ## __VA_ARGS__, nil]; \
}

// Registers an injection point in the current class.
#define inject(...) \
+(void) _alchemic_concat(ALCHEMIC_METHOD_PREFIX, _registerDependencyInClassBuilder):(ALCClassBuilder *) classBuilder { \
[[ALCAlchemic mainContext] registerDependencyInClassBuilder:classBuilder, ## __VA_ARGS__, nil]; \
}
