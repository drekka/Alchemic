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
    [_model addObjectFactory:objectFactory withName:objectFactory.defaultName];
    return objectFactory;
}

-(void) objectFactoryConfig:(ALCClassObjectFactory *) objectFactory, ... {
    NSMutableArray *configArguments = [[NSMutableArray alloc] init];
    alc_loadVarArgsAfterVariableIntoArray(objectFactory, configArguments);
    [objectFactory configureWithOptions:configArguments];
}

-(ALCMethodObjectFactory *) objectFactory:(ALCClassObjectFactory *) objectFactory
                            factoryMethod:(SEL) selector
                               returnType:(Class) returnType, ... {

    [ALCRuntime validateClass:objectFactory.objectClass selector:selector];

    NSMutableArray *factoryArguments = [[NSMutableArray alloc] init];
    alc_loadVarArgsAfterVariableIntoArray(returnType, factoryArguments);

    NSMutableArray *factoryOptions = [[NSMutableArray alloc] init];
    NSArray<id<ALCDependency>> *arguments = [factoryArguments methodArgumentsWithUnexpectedTypeHandler:^(id argument) {
        [factoryOptions addObject:argument];
    }];

    ALCMethodObjectFactory *methodFactory = [[ALCMethodObjectFactory alloc] initWithClass:(Class) returnType
                                                                      parentObjectFactory:objectFactory
                                                                                 selector:selector
                                                                                     args:arguments];
    [methodFactory configureWithOptions:factoryOptions];
    [_model addObjectFactory:methodFactory withName:methodFactory.defaultName];
    return methodFactory;
}

-(void) objectFactory:(ALCClassObjectFactory *) objectFactory initializer:(SEL) initializer, ... {

    [ALCRuntime validateClass:objectFactory.objectClass selector:initializer];

    NSMutableArray *unknownArguments = [[NSMutableArray alloc] init];
    alc_loadVarArgsAfterVariableIntoArray(initializer, unknownArguments);
    NSArray<id<ALCDependency>> *arguments = [unknownArguments methodArgumentsWithUnexpectedTypeHandler:NULL];

    __unused id _ = [[ALCClassObjectFactoryInitializer alloc] initWithObjectFactory:objectFactory
                                                                        initializer:initializer
                                                                               args:arguments];
}

-(void) objectFactory:(ALCClassObjectFactory *) objectFactory vaiableInjection:(NSString *) variable, ... {

    STLog(objectFactory.objectClass, @"Register injection %@.%@", NSStringFromClass(objectFactory.objectClass), variable);
    NSMutableArray *valueArguments = [[NSMutableArray alloc] init];
    alc_loadVarArgsAfterVariableIntoArray(variable, valueArguments);

    Ivar ivar = [ALCRuntime aClass:objectFactory.objectClass variableForInjectionPoint:variable];
    Class varClass = [ALCRuntime typeDataForIVar:ivar].objcClass;
    [objectFactory registerDependency:[valueArguments dependencyWithClass:varClass] forVariable:ivar withName:variable];
}

#pragma mark - Accessing objects

-(id) objectWithClass:(Class)returnType, ... {
    STLog(returnType, @"Manual retrieving an instance of %@", NSStringFromClass([returnType class]));
    NSMutableArray *criteria = [[NSMutableArray alloc] init];
    alc_loadVarArgsAfterVariableIntoArray(returnType, criteria);
    if (criteria.count == 0) {
        [criteria addObject:[ALCModelSearchCriteria searchCriteriaForClass:[returnType class]]];
    }
    ALCModelDependency *dependency = [criteria modelSearchWithClass:returnType];
    [dependency resolveWithStack:[[NSMutableArray alloc] init] model:_model];
    return dependency.searchResult;
}

#pragma mark - Object management

-(void) objectFactory:(id<ALCObjectFactory>) objectFactory
          changedName:(NSString *) oldName
              newName:(NSString *) newName {
    [_model objectFactory:objectFactory
              changedName:oldName
                  newName:newName];
}

@end

NS_ASSUME_NONNULL_END
