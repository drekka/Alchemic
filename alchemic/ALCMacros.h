//
//  ALCMacros.h
//  Alchemic
//
//  Created by Derek Clarkson on 25/03/2016.
//  Copyright © 2016 Derek Clarkson. All rights reserved.
//

#pragma mark - Registering

#import "ALCInternalMacros.h"

#define AcRegister(...) \
+(void) alc_concat(ALCHEMIC_METHOD_PREFIX, _registerClassBuilder):(ALCClassObjectFactory *) classObjectFactory { \
    [[Alchemic mainContext] objectFactoryConfig:classObjectFactory, ## __VA_ARGS__, nil]; \
}

// Registers an injection point in the current class.
#define AcInject(variableName, ...) \
+(void) alc_concat(ALCHEMIC_METHOD_PREFIX, _registerObjectFactoryDependency):(ALCClassObjectFactory *) classObjectFactory { \
    [[Alchemic mainContext] objectFactory:classObjectFactory vaiableInjection:alc_toNSString(variableName), ## __VA_ARGS__, nil]; \
}

#pragma mark - Accessing the model

#define AcGet(returnType, ...) [[Alchemic mainContext] objectWithClass:[returnType class], ## __VA_ARGS__, nil]

#pragma mark - Arguments

#define AcArg(argClass, critieria, ...) [ALCArgument argumentWithClass:[argClass class] model:model criteria:criteria, ## __VA_ARGS__, nil]

#pragma mark - Model search Criteria.

#define AcClass(className) [ALCModelSearchCriteria searchCriteriaForClass:[className class]]

#define AcProtocol(protocolName) [ALCModelSearchCriteria searchCriteriaForProtocol:@protocol(protocolName)]

#define AcName(objectName) [ALCModelSearchCriteria searchCriteriaForName:objectName]

