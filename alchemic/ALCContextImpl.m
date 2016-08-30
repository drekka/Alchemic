//
//  ALCContextImpl.m
//  Alchemic
//
//  Created by Derek Clarkson on 6/02/2016.
//  Copyright © 2016 Derek Clarkson. All rights reserved.
//

@import StoryTeller;

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
#import "ALCModelValueSource.h"
#import "ALCModelSearchCriteria.h"
#import "ALCObjectFactory.h"
#import "ALCRuntime.h"
#import "ALCValue.h"
#import "NSArray+Alchemic.h"
#import "NSObject+Alchemic.h"
#import "ALCVariableDependency.h"
#import "ALCArrayValueSource.h"

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

-(void) addResolveAspect:(id<ALCResolveAspect>) resolveAspect {
    [_model addResolveAspect:resolveAspect];
}

#pragma mark - Registration

-(ALCClassObjectFactory *) registerObjectFactoryForClass:(Class) aClass {
    STLog(aClass, @"Register object factory for %@", NSStringFromClass(aClass));
    ALCClassObjectFactory *objectFactory = [[ALCClassObjectFactory alloc] initWithType:[ALCType typeWithClass:aClass]];
    [_model addObjectFactory:objectFactory withName:nil];
    return objectFactory;
}

-(void) objectFactoryConfig:(ALCClassObjectFactory *) objectFactory, ... {
    alc_loadVarArgsAfterVariableIntoArray(objectFactory, config);
    [self objectFactoryConfig:objectFactory config:config];
}

-(void) objectFactoryConfig:(ALCClassObjectFactory *) objectFactory
                     config:(NSArray *) config {
    [objectFactory configureWithOptions:config model:_model];
}

-(void) objectFactory:(ALCClassObjectFactory *) objectFactory
registerFactoryMethod:(SEL) selector
           returnType:(Class) returnType, ... {
    alc_loadVarArgsAfterVariableIntoArray(returnType, factoryArguments);
    [self objectFactory:objectFactory
  registerFactoryMethod:selector
             returnType:returnType
          configAndArgs:factoryArguments];
}

-(void) objectFactory:(ALCClassObjectFactory *) objectFactory
registerFactoryMethod:(SEL) selector
           returnType:(ALCType *) returnType
        configAndArgs:(NSArray *) configAndArgs {

    // Read in the arguments and sort them into factory config and method arguments.

    NSMutableArray *factoryOptions = [[NSMutableArray alloc] init];
    NSArray<ALCType *> *methodTypes = [ALCRuntime forClass:objectFactory.type.objcClass methodArgumentTypes:selector];
    NSArray<id<ALCDependency>> *methodArguments = [configAndArgs methodArgumentsWithTypes:methodTypes
                                                   unknownArgumentHandler:^(id argument) {
        [factoryOptions addObject:argument];
    }];

    // Build the factory.
    ALCMethodObjectFactory *methodFactory = [[ALCMethodObjectFactory alloc] initWithType:returnType
                                                                      parentObjectFactory:objectFactory
                                                                                 selector:selector
                                                                                     args:methodArguments];
    [_model addObjectFactory:methodFactory withName:nil];
    [methodFactory configureWithOptions:factoryOptions model:_model];
}

-(void) objectFactory:(ALCClassObjectFactory *) objectFactory initializer:(SEL) initializer, ... {
    alc_loadVarArgsAfterVariableIntoArray(initializer, arguments);
    [self objectFactory:objectFactory initializer:initializer args:arguments];
}

-(void) objectFactory:(ALCClassObjectFactory *) objectFactory
          initializer:(SEL) initializer
                 args:(NSArray *) args {

    // Throw an exception if the factory is already set to a reference type.
    if (objectFactory.factoryType == ALCFactoryTypeReference) {
        throwException(IllegalArgument, @"Reference factories cannot have initializers");
    }

    STLog(objectFactory.type.objcClass, @"Register object factory initializer %@", [ALCRuntime forClass:objectFactory.type.objcClass selectorDescription:initializer]);


    NSArray<ALCType *> *methodTypes = [ALCRuntime forClass:objectFactory.type.objcClass methodArgumentTypes:initializer];
    NSArray<id<ALCDependency>> *arguments = [args methodArgumentsWithTypes:methodTypes
                                             unknownArgumentHandler:^(id argument) {
        throwException(IllegalArgument, @"Expected a argument definition, search criteria or constant. Got: %@", argument);
    }];

    __unused id _ = [[ALCClassObjectFactoryInitializer alloc] initWithObjectFactory:objectFactory
                                                                        initializer:initializer
                                                                               args:arguments];
}


-(void) objectFactory:(ALCClassObjectFactory *) objectFactory registerInjection:(NSString *) variable, ... {
    alc_loadVarArgsAfterVariableIntoArray(variable, config);
    Ivar ivar = [ALCRuntime forClass:objectFactory.type.objcClass variableForInjectionPoint:variable];
    ALCType *type = [ALCType typeForIvar:ivar];
    [self objectFactory:objectFactory
      registerInjection:ivar
               withName:variable
                 ofType:type
                 config:config];
}

-(void) objectFactory:(ALCClassObjectFactory *) objectFactory
    registerInjection:(Ivar) variable
             withName:(NSString *) name
               ofType:(ALCType *) type
               config:(NSArray *) config {

    STLog(objectFactory.type.objcClass, @"Register injection %@.%@", NSStringFromClass(objectFactory.type.objcClass), name);

    NSMutableArray<id<ALCValueSource>> *constantValues = [NSMutableArray array];
    NSMutableArray *dependencyConfig = [[NSMutableArray alloc] init];
    ALCModelSearchCriteria *modelSearchCriteria = [config modelSearchCriteriaWithUnknownArgumentHandler:^(id  _Nonnull argument) {
        if ([argument conformsToProtocol:@protocol(ALCValueSource)]) {
            if (![type.objcClass isKindOfClass:[NSArray class]] && constantValues.count > 0) {
                throwException(IllegalArgument, @"More than one constant value found for %@", [ALCRuntime forClass:objectFactory.type.objcClass propertyDescription:name]);
            } else {
                [constantValues addObject:argument];
            }
        } else {
            [dependencyConfig addObject:argument];
        }
    }];

    if (modelSearchCriteria && constantValues) {
        throwException(IllegalArgument, @"Cannot specify both constant values and model search criteria for %@", [ALCRuntime forClass:objectFactory.type.objcClass propertyDescription:name]);
    }

    id<ALCValueSource> source;
    if (modelSearchCriteria) {
        source = [ALCModelValueSource valueSourceWithType:type criteria:modelSearchCriteria];
    } else {
        if (constantValues.count == 1) {
            source = constantValues[0];
        } else {
            source = [ALCArrayValueSource valueSourceWithValueSources:constantValues];
        }
    }
    
    ALCVariableDependency *dependency = [objectFactory registerVariableDependency:variable
                                                                             type:type
                                                                      valueSource:source
                                                                         withName:name];
    [dependency configureWithOptions:dependencyConfig];
}

#pragma mark - Getting, setting and injecting

-(id) objectWithClass:(Class) returnType, ... {
    alc_loadVarArgsAfterVariableIntoArray(returnType, criteria);
    return [self objectWithClass:returnType searchCriteria:criteria];
}

-(id) objectWithClass:(Class) returnType searchCriteria:(NSArray *) criteria {

    // Throw an error if this is called too early.
    if (_postStartBlocks) {
        throwException(Lifecycle, @"AcGet called before Alchemic is ready to serve objects.");
    }

    STLog(returnType, @"Manual retrieving an instance of %@", NSStringFromClass([returnType class]));
    ALCModelSearchCriteria *modelSearchCriteria = [criteria modelSearchCriteriaWithUnknownArgumentHandler:^(id argument) {
        throwException(IllegalArgument, @"Unexpected argument %@", argument);
    }];
    ALCType *type = [ALCType typeWithClass:returnType];
    ALCModelValueSource *source = [ALCModelValueSource valueSourceWithType:type criteria:modelSearchCriteria];
    [source resolveWithStack:[[NSMutableArray alloc] init] model:_model];

    NSError *error;
    id value = [source searchResultWithError:&error];
    if (!value) {
        throwException(MappingValue, @"Mapping error: %@", error.localizedDescription);
    }
    return value;
}

-(void) setObject:(id) object, ... {
    alc_loadVarArgsAfterVariableIntoArray(object, criteria);
    [self setObject:object searchCriteria:criteria];
}

-(void) setObject:(id) object searchCriteria:(NSArray *) criteria {

    // Check for an Alchemic value.
    id finalObject = object;
    if ([object conformsToProtocol:@protocol(ALCValueSource)]) {
        NSError *error;
        finalObject = [(id<ALCValueSource>)object valueWithError:&error];
        if (error) {
            throwException(Resolving, @"Unexpected error accessing value: %@", error);
        }
    }
    
    // Setup a block we want to execute.
    Class objClass = [object class];
    STLog(objClass, @"Storing reference for a %@", NSStringFromClass(objClass));

    ALCSimpleBlock setBlock = ^{

        ALCModelSearchCriteria *searchCriteria = [criteria modelSearchCriteriaWithUnknownArgumentHandler:^(id argument) {
            throwException(IllegalArgument, @"Unexpected criteria: %@", argument);
        }];
        
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

-(void) injectDependencies:(id) object, ... {

    STStartScope(object);

    alc_loadVarArgsAfterVariableIntoArray(object, criteria);
    
    // Throw an error if this is called too early.
    if (_postStartBlocks) {
        throwException(Lifecycle, @"AcInjectDependencies called before Alchemic is ready.");
    }
    
    // We are only interested in class factories.
    ALCModelSearchCriteria *searchCriteria = [criteria modelSearchCriteriaWithUnknownArgumentHandler:^(id argument) {
        throwException(IllegalArgument, @"Unexpected criteria: %@", argument);
    }];

    ALCClassObjectFactory *classFactory = [_model classObjectFactoryMatchingCriteria:searchCriteria];
    
    if (classFactory) {
        STLog(object, @"Starting dependency injection of a %@ ...", NSStringFromClass([object class]));
        [classFactory injectDependencies:object];
    } else {
        STLog(object, @"No class factory found for a %@", NSStringFromClass([object class]));
    }
}


@end

NS_ASSUME_NONNULL_END
