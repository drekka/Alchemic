//
//  ALCContextImpl.m
//  Alchemic
//
//  Created by Derek Clarkson on 6/02/2016.
//  Copyright © 2016 Derek Clarkson. All rights reserved.
//

#import <StoryTeller/StoryTeller.h>

#import "ALCContextImpl.h"
#import "ALCModel.h"
#import "ALCModelImpl.h"
#import "ALCObjectFactory.h"
#import "ALCClassObjectFactory.h"
#import "ALCMethodObjectFactory.h"
#import "ALCClassObjectFactoryInitializer.h"
#import "ALCDependency.h"
#import "ALCModelDependency.h"
#import "ALCConstant.h"
#import "Alchemic.h"
#import "NSArray+Alchemic.h"
#import "ALCRuntime.h"
#import "ALCTypeData.h"
#import "ALCInternalMacros.h"
#import "ALCFactoryName.h"

NS_ASSUME_NONNULL_BEGIN

@implementation ALCContextImpl {
    id<ALCModel> _model;
}

-(instancetype)init {
    self = [super init];
    if (self) {
        _model = [[ALCModelImpl alloc] init];
    }
    return self;
}

-(void) start {
    STStartScope(self);
    STLog(self, @"Starting Alchemic ...");
    [_model resolveDependencies];
    [_model startSingletons];
    STLog(self, @"\n\n%@\n", _model);
    STLog(self, @"Alchemic started.");
}

#pragma mark - Registration

-(ALCClassObjectFactory *) registerObjectFactoryForClass:(Class) clazz {
    STLog(clazz, @"Register object factory for %@", NSStringFromClass(clazz));
    ALCClassObjectFactory *objectFactory = [[ALCClassObjectFactory alloc] initWithClass:clazz];
    [_model addObjectFactory:objectFactory withName:objectFactory.defaultModelKey];
    return objectFactory;
}

-(void) objectFactory:(ALCClassObjectFactory *) objectFactory config:(NSArray *) configArguments {
    [objectFactory configureWithOptions:configArguments unknownOptionHandler:[self unknownOptionHandlerForObjectFactory:objectFactory]];
}

-(void) objectFactoryConfig:(ALCClassObjectFactory *) objectFactory, ... {
    alc_loadVarArgsAfterVariableIntoArray(objectFactory, configArguments);
    [objectFactory configureWithOptions:configArguments unknownOptionHandler:[self unknownOptionHandlerForObjectFactory:objectFactory]];
}

-(void) objectFactory:(ALCClassObjectFactory *) objectFactory
registerFactoryMethod:(SEL) selector
           returnType:(Class) returnType, ... {

    // Read in the arguments and sort them into factory config and method arguments.
    alc_loadVarArgsAfterVariableIntoArray(returnType, factoryArguments);

    NSMutableArray *factoryOptions = [[NSMutableArray alloc] init];
    NSArray<id<ALCDependency>> *methodArguments = [factoryArguments methodArgumentsWithUnknownArgumentHandler:^(id argument) {
        [factoryOptions addObject:argument];
    }];

    // Build the factory.
    ALCMethodObjectFactory *methodFactory = [[ALCMethodObjectFactory alloc] initWithClass:(Class) returnType
                                                                      parentObjectFactory:objectFactory
                                                                                 selector:selector
                                                                                     args:methodArguments];

    [_model addObjectFactory:methodFactory withName:methodFactory.defaultModelKey];
    [methodFactory configureWithOptions:factoryOptions unknownOptionHandler:[self unknownOptionHandlerForObjectFactory:methodFactory]];
}

-(void) objectFactory:(ALCClassObjectFactory *) objectFactory setInitializer:(SEL) initializer, ... {

    STLog(objectFactory.objectClass, @"Register object factory initializer %@", [ALCRuntime selectorDescription:objectFactory.objectClass selector:initializer]);
    
    alc_loadVarArgsAfterVariableIntoArray(initializer, unknownArguments);

    NSArray<id<ALCDependency>> *arguments = [unknownArguments methodArgumentsWithUnknownArgumentHandler:^(id argument) {
        throwException(@"AlchemicIllegalArgument", nil, @"Expected a argument definition, search criteria or constant. Got: %@", argument);
    }];

    __unused id _ = [[ALCClassObjectFactoryInitializer alloc] initWithObjectFactory:objectFactory
                                                                     setInitializer:initializer
                                                                               args:arguments];
}

-(void) objectFactory:(ALCClassObjectFactory *) objectFactory registerVariableInjection:(NSString *) variable, ... {

    STLog(objectFactory.objectClass, @"Register injection %@.%@", NSStringFromClass(objectFactory.objectClass), variable);

    alc_loadVarArgsAfterVariableIntoArray(variable, valueArguments);

    Ivar ivar = [ALCRuntime aClass:objectFactory.objectClass variableForInjectionPoint:variable];
    Class varClass = [ALCRuntime typeDataForIVar:ivar].objcClass;
    [objectFactory registerDependency:[valueArguments dependencyWithClass:varClass] forVariable:ivar withName:variable];
}

#pragma mark - Dependencies

- (void)injectDependencies:(id)object {
    STStartScope(object);
    STLog(object, @"Starting dependency injection of a %@ ...", NSStringFromClass([object class]));
    NSDictionary<NSString *, id<ALCObjectFactory>> *factories = [_model objectFactoriesMatchingCriteria:[ALCModelSearchCriteria searchCriteriaForClass:[object class]]];
    [[factories.allValues firstObject] injectDependencies:object];
}

#pragma mark - Accessing objects

-(id) objectWithClass:(Class)returnType, ... {
    STLog(returnType, @"Manual retrieving an instance of %@", NSStringFromClass([returnType class]));

    alc_loadVarArgsAfterVariableIntoArray(returnType, criteria);
    if (criteria.count == 0) {
        [criteria addObject:[ALCModelSearchCriteria searchCriteriaForClass:[returnType class]]];
    }
    ALCModelDependency *dependency = [criteria modelSearchWithClass:returnType];
    [dependency resolveWithStack:[[NSMutableArray alloc] init] model:_model];
    return [ALCRuntime mapValue:dependency.searchResult toType:returnType];
}

#pragma mark - Internal

-(void (^)(id option)) unknownOptionHandlerForObjectFactory:(id<ALCObjectFactory>) objectFactory {
    return ^(id option) {
        if ([(NSObject *) option isKindOfClass:[ALCFactoryName class]]) {
            [self->_model objectFactory:objectFactory
                            changedName:objectFactory.defaultModelKey
                                newName:((ALCFactoryName *) option).asName];
        } else {
            throwException(@"AlchemicIllegalArgument", nil, @"Expected a factory config macro");
        }
    };
}

@end

NS_ASSUME_NONNULL_END
