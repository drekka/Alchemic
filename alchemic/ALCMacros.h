//
//  ALCMacros.h
//  alchemic
//
//  Created by Derek Clarkson on 23/06/2015.
//  Copyright © 2015 Derek Clarkson. All rights reserved.
//

#pragma mark - Defining objects

#define ACAsName(_objectName) [ALCAsName asNameWithName:_objectName]

#define ACIsFactory [[ALCIsFactory alloc] init]

#define ACIsPrimary [[ALCIsPrimary alloc] init]

#pragma mark - Dependency matching

#define ACWithClass(_className) [ALCClassMatcher matcherWithClass:[_className class]]

#define ACWithProtocol(_protocolName) [ALCProtocolMatcher matcherWithProtocol:@protocol(_protocolName)]

#define ACWithName(_objectName) [ALCNameMatcher matcherWithName:_objectName]

#define ACReturnType(_returnType) [ALCReturnType returnTypeWithClass:[_returnType class]]

#define ACFactorySelector(_methodSelector) [ALCMethodSelector methodSelector:@selector(_methodSelector)]

#define ACIntoVariable(_variableName) [ALCIntoVariable intoVariableWithName:_alchemic_toNSString(_variableName)]

#pragma mark - Injection

#define ACInjectDependencies(object) [[ALCAlchemic mainContext] injectDependencies:object]

#pragma mark - Registering

// All registration methods make use of the same signature.
#define ACRegister(...) \
+(void) _alchemic_concat(ALCHEMIC_METHOD_PREFIX, _registerClassBuilder):(ALCClassBuilder *) classBuilder { \
[[ALCAlchemic mainContext] registerClassBuilder:classBuilder, ## __VA_ARGS__, nil]; \
}

// Registers an injection point in the current class.
#define ACInject(...) \
+(void) _alchemic_concat(ALCHEMIC_METHOD_PREFIX, _registerDependencyInClassBuilder):(ALCClassBuilder *) classBuilder { \
[[ALCAlchemic mainContext] registerDependencyInClassBuilder:classBuilder, ## __VA_ARGS__, nil]; \
}
