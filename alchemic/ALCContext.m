//
//  AlchemicContext.m
//  alchemic
//
//  Created by Derek Clarkson on 15/02/2015.
//  Copyright (c) 2015 Derek Clarkson. All rights reserved.
//

#import <objc/runtime.h>

#import "Alchemic.h"
#import "ALCContext.h"
#import "ALCLogger.h"

#import "ALCRuntime.h"
#import "ALCRuntimeFunctions.h"

#import "AlchemicAware.h"

#import "ALCObjectDescription.h"
#import "ALCInitialisationStrategyInjector.h"

#import "ALCClassDependencyResolver.h"
#import "ALCProtocolDependencyResolver.h"
#import "ALCNameDependencyResolver.h"

#import "ALCDependency.h"

#import "ALCSimpleDependencyInjector.h"

#import "ALCObjectFactory.h"
#import "ALCSimpleObjectFactory.h"

#import "ALCNSObjectInitStrategy.h"
#import "ALCUIViewControllerInitWithCoderStrategy.h"
#import "ALCUIViewControllerInitWithFrameStrategy.h"

#import "NSDictionary+ALCModel.h"

@implementation ALCContext {
    NSMutableArray *_initialisationStrategies;
    NSMutableArray *_dependencyResolvers;
    NSMutableArray *_dependencyInjectors;
    NSMutableArray *_objectFactories;
    NSMutableDictionary *_model;
    NSMutableDictionary *_objects;
}

-(instancetype) init {
    self = [super init];
    if (self) {
        
        logConfig(@"Initing context");
        
        // Create storage for objects.
        _model = [[NSMutableDictionary alloc] init];
        _objects = [[NSMutableDictionary alloc] init];
        
        _initialisationStrategies = [[NSMutableArray alloc] init];
        [self addInitialisationStrategy:[[ALCNSObjectInitStrategy alloc] init]];
        [self addInitialisationStrategy:[[ALCUIViewControllerInitWithCoderStrategy alloc] init]];
        [self addInitialisationStrategy:[[ALCUIViewControllerInitWithFrameStrategy alloc] init]];
        
        _objectFactories = [[NSMutableArray alloc] init];
        [self addObjectFactory:[[ALCSimpleObjectFactory alloc] initWithContext:self]];
        
        _dependencyResolvers = [[NSMutableArray alloc] init];
        [self addDependencyResolver:[[ALCProtocolDependencyResolver alloc] initWithModel:_model]];
        [self addDependencyResolver:[[ALCClassDependencyResolver alloc] initWithModel:_model]];
        [self addDependencyResolver:[[ALCNameDependencyResolver alloc] initWithModel:_model]];
        
        _dependencyInjectors = [[NSMutableArray alloc] init];
        [self addDependencyInjector:[[ALCSimpleDependencyInjector alloc] init]];
        
    }
    return self;
}

-(void) start {
    
    logRuntime(@"Starting alchemic");
    
    // Set defaults.
    if (self.runtimeInjector == nil) {
        self.runtimeInjector = [[ALCInitialisationStrategyInjector alloc] initWithStrategies:_initialisationStrategies];
    }
    
    // Inject wrappers into the singletons that have registered for dependency injection.
    [_runtimeInjector executeStrategiesOnObjects:_objects withContext:self];
    
    // First we need to connect up all the dependencies.
    [self resolveDependencies];
    
    // Now initiate the objects and finishing injecting dependencies.
    [self instantiateObjects];
    [self injectDependencies];
    
}

-(void) resolveDependencies {
    logDependencyResolving(@"Resolving dependencies ...");
    [_model enumerateKeysAndObjectsUsingBlock:^(NSString *name, ALCObjectDescription *description, BOOL *stop){
        logDependencyResolving(@"Resolving dependencies in '%@' (%s)", name, class_getName(description.forClass));
        [description resolveDependenciesInModel:_model usingResolvers:_dependencyResolvers];
    }];
}

-(void) instantiateObjects {
    logCreation(@"Instantiating objects ...");
    [_model enumerateKeysAndObjectsUsingBlock:^(NSString *name, ALCObjectDescription *description, BOOL *stop) {
        if (description.createInstance && description.finalObject == nil) { // Allow for pre-built objects.
            logCreation(@"Instantiating '%@' (%s)", description.name, class_getName(description.forClass));
            [description instantiateUsingFactories:_objectFactories];
        }
    }];
}

-(void) injectDependencies {
    logDependencyResolving(@"Injecting dependencies ...");
    [_model enumerateKeysAndObjectsUsingBlock:^(NSString *name, ALCObjectDescription *description, BOOL *stop) {
        if (description.createInstance) {
            logDependencyResolving(@"Injecting dependencies into '%@'", name);
            [description injectDependenciesUsingInjectors:_dependencyInjectors];
        }
    }];
}

#pragma mark - The model

-(void) registerClass:(Class) class injectionPoints:(NSString *) injs, ... {

    // Find any current description for the class.
    ALCObjectDescription *description = [self objectDescriptionForClass:class withQualifier:nil];
    
    va_list args;
    va_start(args, injs);
    for (NSString *inj = injs; inj != nil; inj = va_arg(args, NSString *)) {
        [self addInjection:inj
             withQualifier:nil
       toObjectDescription:description];
    }
    va_end(args);
}

-(void) registerClass:(Class)class {
    [self registerClass:class withName:NSStringFromClass(class)];
}

-(void) registerClass:(Class)class withName:(NSString *) name {
    ALCObjectDescription *description = [self objectDescriptionForClass:class withQualifier:name];
    description.createInstance = YES;
    // Update the name which may be a default if the object description was created during field registration.
    description.name = name;
}

-(void) addInjection:(NSString *) inj
       withQualifier:(NSString *) qualifier
 toObjectDescription:(ALCObjectDescription *) objectDescription {

    Ivar variable = [ALCRuntime variableInClass:objectDescription.forClass forInjectionPoint:[inj UTF8String]];
    
    ALCDependency *dependency = [[ALCDependency alloc] initWithVariable:variable
                                                              qualifier:qualifier
                                                            parentClass:objectDescription.forClass];
    logRegistration(@"Registering: '%@' (%s::%s)->%@", objectDescription.name, class_getName(objectDescription.forClass), ivar_getName(variable), dependency.variableTypeEncoding);
    [objectDescription addDependency:dependency];
}

-(ALCObjectDescription *) objectDescriptionForClass:(Class) class withQualifier:(NSString *) qualifier {
 
    ALCObjectDescription *description = nil;
    
    // First look to see what is already a match.
    NSDictionary *candidates = [_model objectDescriptionsForClass:class
                                                        protocols:nil
                                                        qualifier:qualifier
                                                   usingResolvers:_dependencyResolvers];
    if (candidates != nil) {
        return candidates.allValues[0];
    }
    
    if (description == nil) {
        logRegistration(@"Creating info for '%2$s' (%1$@)", qualifier, class_getName(class));
        description = [[ALCObjectDescription alloc] initWithClass:class name:qualifier == nil ? NSStringFromClass(class) : qualifier];
        _model[description.name] = description;
    }
    return description;
}

#pragma mark - Registering objects directly

-(void) registerObject:(id) finalObject withName:(NSString *) name {
    logCreation(@"Storing '%@' (%s)", name, class_getName([finalObject class]));
    ALCObjectDescription *description = [self objectDescriptionForClass:[finalObject class] withQualifier:name];
    description.finalObject = finalObject;
}

#pragma mark - Objects

-(void) addObject:(id) object {
    [self addObject:object withName:NSStringFromClass([object class])];
}

-(void) addObject:(id) object withName:(NSString *)name {
    if (_objects[name] != nil) {
        @throw [NSException exceptionWithName:@"AlchemicDuplicateObjectName"
                                       reason:[NSString stringWithFormat:@"Cannot register more than one object with name: %@", name]
                                     userInfo:nil];
    }
    _objects[name] = object;
}

#pragma mark - Retrieving objects

-(id) objectWithName:(NSString *) name {
    return ((ALCObjectDescription *)_model[name]).finalObject;
}

-(void) injectDependencies:(id) object {
    
}

#pragma mark - Configuration

-(void) addObjectFactory:(id<ALCObjectFactory>) objectFactory {
    logConfig(@"Adding object factory: %s", class_getName([objectFactory class]));
    [_objectFactories insertObject:objectFactory atIndex:0];
}

-(void) addInitialisationStrategy:(id<ALCInitialisationStrategy>) initialisationStrategy {
    logConfig(@"Adding init strategy: %s", class_getName([initialisationStrategy class]));
    [_initialisationStrategies insertObject:initialisationStrategy atIndex:0];
}

-(void) addDependencyResolver:(id<ALCDependencyResolver>) dependencyResolver {
    logConfig(@"Adding dependency resolver: %s", class_getName([dependencyResolver class]));
    [_dependencyResolvers insertObject:dependencyResolver atIndex:0];
}

-(void) addDependencyInjector:(id<ALCDependencyInjector>) dependencyinjector {
    logConfig(@"Adding dependency injector: %s", class_getName([dependencyinjector class]));
    [_dependencyInjectors insertObject:dependencyinjector atIndex:0];
}

@end
