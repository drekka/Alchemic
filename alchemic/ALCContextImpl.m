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
#import "ALCModelObjectInjector.h"
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
    
    // Post the finished notification.
    [[NSNotificationCenter defaultCenter] postNotificationName:AlchemicDidFinishStarting object:self];
}

#pragma mark - Registration

-(ALCClassObjectFactory *) registerObjectFactoryForClass:(Class) clazz {
    STLog(clazz, @"Register object factory for %@", NSStringFromClass(clazz));
    ALCClassObjectFactory *objectFactory = [[ALCClassObjectFactory alloc] initWithClass:clazz];
    [_model addObjectFactory:objectFactory withName:objectFactory.defaultModelKey];
    return objectFactory;
}

-(void) objectFactoryConfig:(ALCClassObjectFactory *) objectFactory, ... {
    alc_loadVarArgsAfterVariableIntoArray(objectFactory, configArguments);
    [self objectFactory:objectFactory config:configArguments];
}

-(void) objectFactory:(ALCClassObjectFactory *) objectFactory config:(NSArray *) configArguments {
    [objectFactory configureWithOptions:configArguments customOptionHandler:[self unknownOptionHandlerForObjectFactory:objectFactory]];
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
    [methodFactory configureWithOptions:factoryOptions customOptionHandler:[self unknownOptionHandlerForObjectFactory:methodFactory]];
}

-(void) objectFactory:(ALCClassObjectFactory *) objectFactory setInitializer:(SEL) initializer, ... {
    
    // Throw an exception if the factory is already set to a reference type.
    if (objectFactory.factoryType == ALCFactoryTypeReference) {
        throwException(IllegalArgument, @"Reference factories cannot have initializers");
    }
    
    STLog(objectFactory.objectClass, @"Register object factory initializer %@", [ALCRuntime selectorDescription:objectFactory.objectClass selector:initializer]);
    
    alc_loadVarArgsAfterVariableIntoArray(initializer, unknownArguments);
    
    NSArray<id<ALCDependency>> *arguments = [unknownArguments methodArgumentsWithUnknownArgumentHandler:^(id argument) {
        throwException(IllegalArgument, @"Expected a argument definition, search criteria or constant. Got: %@", argument);
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
    id<ALCInjector> injection = [valueArguments injectionWithClass:varClass allowConstants:YES];
    [objectFactory registerInjection:injection forVariable:ivar withName:variable];
}

#pragma mark - Dependencies

- (void)injectDependencies:(id)object {
    
    STStartScope(object);
    
    // We are only interested in class factories.
    ALCClassObjectFactory *classFactory = [_model classObjectFactoryForClass:[object class]];
    
    if (classFactory) {
        STLog(object, @"Starting dependency injection of a %@ ...", NSStringFromClass([object class]));
        [classFactory injectDependencies:object];
    } else {
        STLog(object, @"No class factory found for a %@", NSStringFromClass([object class]));
    }
}

#pragma mark - Accessing objects

-(id) objectWithClass:(Class)returnType, ... {
    STLog(returnType, @"Manual retrieving an instance of %@", NSStringFromClass([returnType class]));
    
    alc_loadVarArgsAfterVariableIntoArray(returnType, criteria);
    if (criteria.count == 0) {
        [criteria addObject:[ALCModelSearchCriteria searchCriteriaForClass:[returnType class]]];
    }
    ALCModelObjectInjector *injection = (ALCModelObjectInjector *)[criteria injectionWithClass:returnType allowConstants:NO];
    [injection resolveWithStack:[[NSMutableArray alloc] init] model:_model];
    return injection.searchResult;
}

#pragma mark - Internal

-(void (^)(id option)) unknownOptionHandlerForObjectFactory:(id<ALCObjectFactory>) objectFactory {
    return ^(id option) {
        if ([(NSObject *) option isKindOfClass:[ALCFactoryName class]]) {
            NSString *newName = ((ALCFactoryName *) option).asName;
            [self->_model reindexObjectFactoryOldName:objectFactory.defaultModelKey newName:newName];
        } else {
            throwException(IllegalArgument, @"Expected a factory config macro");
        }
    };
}

@end

NS_ASSUME_NONNULL_END
