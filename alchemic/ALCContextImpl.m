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
#import "ALCModelObjectInjector.h"
#import "ALCModelSearchCriteria.h"
#import "ALCObjectFactory.h"
#import "ALCRuntime.h"
#import "ALCTypeData.h"
#import "NSArray+Alchemic.h"
#import "NSObject+Alchemic.h"
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
           returnType:(Class) returnType
        configAndArgs:(NSArray *) configAndArgs {

    // Read in the arguments and sort them into factory config and method arguments.

    NSMutableArray *factoryOptions = [[NSMutableArray alloc] init];
    NSArray<id<ALCDependency>> *methodArguments = [configAndArgs methodArgumentsWithUnknownArgumentHandler:^(id argument) {
        [factoryOptions addObject:argument];
    }];

    // Build the factory.
    ALCMethodObjectFactory *methodFactory = [[ALCMethodObjectFactory alloc] initWithClass:returnType
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

    STLog(objectFactory.objectClass, @"Register object factory initializer %@", [ALCRuntime class:objectFactory.objectClass selectorDescription:initializer]);

    NSArray<id<ALCDependency>> *arguments = [args methodArgumentsWithUnknownArgumentHandler:^(id argument) {
        throwException(IllegalArgument, @"Expected a argument definition, search criteria or constant. Got: %@", argument);
    }];

    __unused id _ = [[ALCClassObjectFactoryInitializer alloc] initWithObjectFactory:objectFactory
                                                                        initializer:initializer
                                                                               args:arguments];
}


-(void) objectFactory:(ALCClassObjectFactory *) objectFactory registerInjection:(NSString *) variable, ... {
    alc_loadVarArgsAfterVariableIntoArray(variable, config);
    Ivar ivar = [ALCRuntime class:objectFactory.objectClass variableForInjectionPoint:variable];
    Class varClass = [ALCRuntime typeDataForIVar:ivar].objcClass;
    [self objectFactory:objectFactory
      registerInjection:ivar
               withName:variable
                 ofType:varClass
                 config:config];
}

-(void) objectFactory:(ALCClassObjectFactory *) objectFactory
    registerInjection:(Ivar) variable
             withName:(NSString *) name
               ofType:(Class) type
               config:(NSArray *) config {

    STLog(objectFactory.objectClass, @"Register injection %@.%@", NSStringFromClass(objectFactory.objectClass), name);

    NSMutableArray *dependencyConfig = [[NSMutableArray alloc] init];
    __block BOOL allowNils = NO;
    id<ALCInjector> injector = [config injectorForClass:type
                                         allowConstants:YES
                                 unknownArgumentHandler:^(id argument) {
                                     [dependencyConfig addObject:argument];
                                 }];
    injector.allowNilValues = allowNils;

    ALCVariableDependency *dependency = [objectFactory registerVariableDependency:variable
                                                                         injector:injector
                                                                         withName:name];
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
    alc_loadVarArgsAfterVariableIntoArray(returnType, criteria);
    return [self objectWithClass:returnType searchCriteria:criteria];
}

-(id) objectWithClass:(Class) returnType searchCriteria:(NSArray *) criteria {

    // Throw an error if this is called to early.
    if (_postStartBlocks) {
        throwException(Lifecycle, @"AcGet called before Alchemic is ready to serve objects.");
    }

    STLog(returnType, @"Manual retrieving an instance of %@", NSStringFromClass([returnType class]));
    NSArray *finalCriteria = criteria;
    if (finalCriteria.count == 0) {
        finalCriteria = [finalCriteria arrayByAddingObject:[ALCModelSearchCriteria searchCriteriaForClass:[returnType class]]];
    }

    ALCModelObjectInjector *injection = (ALCModelObjectInjector *)[finalCriteria injectorForClass:returnType
                                                                                   allowConstants:NO
                                                                           unknownArgumentHandler:NULL];
    [injection resolveWithStack:[[NSMutableArray alloc] init] model:_model];

    NSError *error;
    id value = [injection searchResultWithError:&error];
    if (!value && error) {
        throwException(MappingValue, @"Mapping error: %@", error.localizedDescription);
    }
    return value;
}

-(void) setObject:(id) object, ... {
    alc_loadVarArgsAfterVariableIntoArray(object, criteria);
    [self setObject:object searchCriteria:criteria];
}

-(void) setObject:(id) object searchCriteria:(NSArray *) criteria {

    // Setup a block we want to execute.
    id finalObject = [object isKindOfClass:[ALCConstantNil class]] ? nil : object;
    Class objClass = [object class];
    STLog(objClass, @"Storing reference for a %@", NSStringFromClass(objClass));

    ALCSimpleBlock setBlock = ^{

        NSArray *finalCriteria = criteria;
        if (finalCriteria.count == 0) {
            if (!finalObject) {
                throwException(IncorrectNumberOfArguments, @"When setting nil, at least one search criteria is needed to find the relevant object factory");
            } else {
                finalCriteria = [finalCriteria arrayByAddingObject:[ALCModelSearchCriteria searchCriteriaForClass:objClass]];
            }
        }

        ALCModelSearchCriteria *searchCriteria = [finalCriteria modelSearchCriteriaForClass:objClass];
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

@end

NS_ASSUME_NONNULL_END
