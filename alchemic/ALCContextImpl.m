//
//  ALCContextImpl.m
//  Alchemic
//
//  Created by Derek Clarkson on 6/02/2016.
//  Copyright © 2016 Derek Clarkson. All rights reserved.
//

@import StoryTeller;
// :: Framework ::
#import <Alchemic/ALCClassObjectFactory.h>
#import <Alchemic/ALCClassObjectFactoryInitializer.h>
#import <Alchemic/ALCConstant.h>
#import <Alchemic/ALCContextImpl.h>
#import <Alchemic/ALCDependency.h>
#import <Alchemic/ALCException.h>
#import <Alchemic/ALCFactoryName.h>
#import <Alchemic/ALCMacros.h>
#import <Alchemic/ALCInternalMacros.h>
#import <Alchemic/ALCMethodObjectFactory.h>
#import <Alchemic/ALCModel.h>
#import <Alchemic/ALCModelImpl.h>
#import <Alchemic/ALCModelObjectInjector.h>
#import <Alchemic/ALCModelSearchCriteria.h>
#import <Alchemic/ALCObjectFactory.h>
#import <Alchemic/ALCRuntime.h>
#import <Alchemic/ALCTypeData.h>
#import <Alchemic/NSArray+Alchemic.h>


NS_ASSUME_NONNULL_BEGIN

@implementation ALCContextImpl {
    id<ALCModel> _model;
    NSMutableSet<ALCSimpleBlock> *_postStartBlocks;
}

-(instancetype)init {
    self = [super init];
    if (self) {
        _model = [[ALCModelImpl alloc] init];
        _postStartBlocks = [[NSMutableSet alloc] init];
    }
    return self;
}

-(void) start {
    STStartScope(self);
    STLog(self, @"Starting Alchemic ...");
    [_model resolveDependencies];
    [_model startSingletons];
    
    // Call and registered blocks.
    [_postStartBlocks enumerateObjectsUsingBlock:^(ALCSimpleBlock postStartBlock, BOOL *stop) {
        postStartBlock();
    }];
    _postStartBlocks = nil; // Clear the blocks.
    
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

-(void) setObject:(id) object, ... {
    STLog([object class], @"Storing reference for a %@", NSStringFromClass([object class]));
    
    // Now lets find our reference object
    alc_loadVarArgsAfterVariableIntoArray(object, criteria);
    if (criteria.count == 0) {
        [criteria addObject:[ALCModelSearchCriteria searchCriteriaForClass:[object class]]];
    }
    
    ALCModelSearchCriteria *searchCriteria = [criteria modelSearchCriteriaForClass:[object class]];
    NSArray<id<ALCObjectFactory>> *factories = [_model settableObjectFactoriesMatchingCriteria:searchCriteria];
    
    // Error if we do not find one factory.
    if (factories.count != 1) {
        throwException(UnableToSetReference, @"Expected 1 factory using criteria %@, found %lu", searchCriteria, factories.count);
    }
    
    // Set the object and call the returned completion.
    [((ALCAbstractObjectFactory *)factories[0]) setObject:object](object);
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
