//
//  ALCContextImpl.m
//  Alchemic
//
//  Created by Derek Clarkson on 6/02/2016.
//  Copyright © 2016 Derek Clarkson. All rights reserved.
//

@import StoryTeller;
// :: Framework ::
#import "ALCClassObjectFactory.h"
#import "ALCClassObjectFactoryInitializer.h"
#import "ALCConstant.h"
#import "ALCContextImpl.h"
#import "ALCDependency.h"
#import "ALCException.h"
#import "ALCFactoryName.h"
#import "ALCMacros.h"
#import "ALCInternalMacros.h"
#import "ALCMethodObjectFactory.h"
#import "ALCModel.h"
#import "ALCModelImpl.h"
#import "ALCModelObjectInjector.h"
#import "ALCModelSearchCriteria.h"
#import "ALCObjectFactory.h"
#import "ALCRuntime.h"
#import "ALCTypeData.h"
#import <Alchemic/NSArray+Alchemic.h>
#import <Alchemic/NSObject+Alchemic.h>
#import "ALCVariableDependency.h"

NS_ASSUME_NONNULL_BEGIN

@implementation ALCContextImpl {
    id<ALCModel> _model;
    NSMutableSet<ALCSimpleBlock> *_postStartBlocks;
}

#pragma mark - Lifecycle

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
    
    // Whilst not common, this executes certain functions which can be called before registrations have finished. ie AcSet()'s in initial view controllers, etc.
    
    // Move the post startup blocks away so other threads think we are started.
    STLog(self, @"Executing post startup blocks");
    NSSet<ALCSimpleBlock> *blocks = _postStartBlocks;
    _postStartBlocks = nil;
    // Now execute any stored blocks.
    [blocks enumerateObjectsUsingBlock:^(ALCSimpleBlock postStartBlock, BOOL *stop) {
        postStartBlock();
    }];
    
    STLog(self, @"Alchemic started.\n\n%@\n", _model);
    
    // Post the finished notification.
    [[NSNotificationCenter defaultCenter] postNotificationName:AlchemicDidFinishStarting object:self];
}

-(void) executeBlockWhenStarted:(void (^)()) block {
    @synchronized (_postStartBlocks) {
        if (_postStartBlocks) {
            [_postStartBlocks addObject:block];
        } else {
            block();
        }
    }
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
    ALCMethodObjectFactory *methodFactory = [[ALCMethodObjectFactory alloc] initWithClass:returnType
                                                                      parentObjectFactory:objectFactory
                                                                                 selector:selector
                                                                                     args:methodArguments];
    
    [_model addObjectFactory:methodFactory withName:methodFactory.defaultModelKey];
    [methodFactory configureWithOptions:factoryOptions model:_model];
}

-(void) objectFactory:(ALCClassObjectFactory *) objectFactory initializer:(SEL) initializer, ... {
    
    // Throw an exception if the factory is already set to a reference type.
    if (objectFactory.factoryType == ALCFactoryTypeReference) {
        throwException(IllegalArgument, @"Reference factories cannot have initializers");
    }
    
    STLog(objectFactory.objectClass, @"Register object factory initializer %@", [ALCRuntime class:objectFactory.objectClass selectorDescription:initializer]);
    
    alc_loadVarArgsAfterVariableIntoArray(initializer, unknownArguments);
    
    NSArray<id<ALCDependency>> *arguments = [unknownArguments methodArgumentsWithUnknownArgumentHandler:^(id argument) {
        throwException(IllegalArgument, @"Expected a argument definition, search criteria or constant. Got: %@", argument);
    }];
    
    __unused id _ = [[ALCClassObjectFactoryInitializer alloc] initWithObjectFactory:objectFactory
                                                                        initializer:initializer
                                                                               args:arguments];
}

-(void) objectFactory:(ALCClassObjectFactory *) objectFactory registerVariableInjection:(NSString *) variable, ... {
    
    STLog(objectFactory.objectClass, @"Register injection %@.%@", NSStringFromClass(objectFactory.objectClass), variable);
    
    alc_loadVarArgsAfterVariableIntoArray(variable, valueArguments);
    
    Ivar ivar = [ALCRuntime class:objectFactory.objectClass variableForInjectionPoint:variable];
    Class varClass = [ALCRuntime typeDataForIVar:ivar].objcClass;
    NSMutableArray *dependencyConfig = [[NSMutableArray alloc] init];
    __block BOOL allowNils = NO;
    id<ALCInjector> injector = [valueArguments injectorForClass:varClass
                                                 allowConstants:YES
                                         unknownArgumentHandler:^(id argument) {
                                             [dependencyConfig addObject:argument];
                                         }];
    injector.allowNilValues = allowNils;
    ALCVariableDependency *dependency = [objectFactory registerVariableDependency:ivar injector:injector withName:variable];
    [dependency configureWithOptions:dependencyConfig];
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

-(id) objectWithClass:(Class) returnType, ... {
    
    // Throw an error if this is called to early.
    if (_postStartBlocks) {
        throwException(Lifecycle, @"AcGet called before Alchemic is ready to serve objects.");
    }
    
    STLog(returnType, @"Manual retrieving an instance of %@", NSStringFromClass([returnType class]));
    
    alc_loadVarArgsAfterVariableIntoArray(returnType, criteria);
    if (criteria.count == 0) {
        [criteria addObject:[ALCModelSearchCriteria searchCriteriaForClass:[returnType class]]];
    }
    
    ALCModelObjectInjector *injection = (ALCModelObjectInjector *)[criteria injectorForClass:returnType
                                                                              allowConstants:NO
                                                                      unknownArgumentHandler:NULL];
    [injection resolveWithStack:[[NSMutableArray alloc] init] model:_model];
    return injection.searchResult;
}

-(void) setObject:(id) object, ... {
    
    // Now lets find our reference object
    alc_loadVarArgsAfterVariableIntoArray(object, criteria);
    
    // Setup a block we want to execute.
    id finalObject = [object isKindOfClass:[ALCConstantNil class]] ? nil : object;
    Class objClass = [object class];
    STLog(objClass, @"Storing reference for a %@", NSStringFromClass(objClass));
    
    ALCSimpleBlock setBlock = ^{
        
        if (criteria.count == 0) {
            if (!finalObject) {
                throwException(IncorrectNumberOfArguments, @"When setting nil, at least one search criteria is needed to find the relevant object factory");
            } else {
                [criteria addObject:[ALCModelSearchCriteria searchCriteriaForClass:objClass]];
            }
        }
        
        ALCModelSearchCriteria *searchCriteria = [criteria modelSearchCriteriaForClass:objClass];
        NSArray<id<ALCObjectFactory>> *factories = [self->_model settableObjectFactoriesMatchingCriteria:searchCriteria];
        
        // Error if we do not find one factory.
        if (factories.count != 1) {
            throwException(UnableToSetReference, @"Expected 1 factory using criteria %@, found %lu", searchCriteria, (unsigned long) factories.count);
        }
        
        // Set the object and call the returned completion.
        [((ALCAbstractObjectFactory *)factories[0]) setObject:finalObject];
    };
    
    // If startup blocks have not been executed yet then there may be registrations which need to occur, so add the block to the list.
    [self executeBlockWhenStarted:setBlock];
}

#pragma mark - Internal

-(void) objectFactory:(ALCClassObjectFactory *) objectFactory config:(NSArray *) options {
    [objectFactory configureWithOptions:options model:_model];
}

-(BOOL) processFactoryNameMacro:(NSObject *) macro forObjectFactory:(id<ALCObjectFactory>) objectFactory {
    if ([macro isKindOfClass:[ALCFactoryName class]]) {
        NSString *newName = ((ALCFactoryName *) macro).asName;
        [_model reindexObjectFactoryOldName:objectFactory.defaultModelKey newName:newName];
        return YES;
    }
    return NO;
}

@end

NS_ASSUME_NONNULL_END
