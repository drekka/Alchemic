//
//  ALCMacros.h
//  Alchemic
//
//  Created by Derek Clarkson on 25/03/2016.
//  Copyright © 2016 Derek Clarkson. All rights reserved.
//

#pragma mark - Registering

//#define AcRegister(...) \
//+(void) alc_concat(ALCHEMIC_METHOD_PREFIX, _registerClassBuilder):(ALCCLassObjectFactory *) classObjectFactory { \
//    [[ALCAlchemic mainContext] registerClassBuilder:classBuilder, ## __VA_ARGS__, nil]; \
//}

// Registers an injection point in the current class.
#define AcInject(variableName, ...) \
+(void) alc_concat(ALCHEMIC_METHOD_PREFIX, _registerObjectFactoryDependency):(ALCClassObjectFactory *) classObjectFactory { \
[[ALCAlchemic mainContext] registerObjectFactory:classObjectFactory variableInjection:alc_toNSString(variableName), ## __VA_ARGS__, nil]; \
}

#pragma mark - Arguments

#define AcArg(argClass, critieria, ...) [ALCArgument argumentWithClass:[argClass class] model:model criteria:criteria, ## __VA_ARGS__, nil]

#pragma mark - Model search Criteria.

#define AcClass(className) [ALCModelSearchCriteria searchCriteriaForClass:[className class]]

#define AcProtocol(protocolName) [ALCModelSearchCriteria searchCriteriaForProtocol:@protocol(protocolName)]

#define AcName(objectName) [ALCModelSearchCriteria searchCriteriaForName:objectName]

