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
#import "ALCWithName.h"

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
    alc_loadVarArgsAfterVariableIntoArray(objectFactory, configArguments);
    [objectFactory configureWithOptions:configArguments unknownOptionHandler:[self unknownOptionHandlerForObjectFactory:objectFactory]];
}

-(ALCMethodObjectFactory *) objectFactory:(ALCClassObjectFactory *) objectFactory
                            factoryMethod:(SEL) selector
                               returnType:(Class) returnType, ... {

    [ALCRuntime validateClass:objectFactory.objectClass selector:selector];

    alc_loadVarArgsAfterVariableIntoArray(returnType, factoryArguments);

    NSMutableArray *factoryOptions = [[NSMutableArray alloc] init];
    NSArray<id<ALCDependency>> *arguments = [factoryArguments methodArgumentsWithUnknownArgumentHandler:^(id argument) {
        [factoryOptions addObject:argument];
    }];

    ALCMethodObjectFactory *methodFactory = [[ALCMethodObjectFactory alloc] initWithClass:(Class) returnType
                                                                      parentObjectFactory:objectFactory
                                                                                 selector:selector
                                                                                     args:arguments];

    [_model addObjectFactory:methodFactory withName:methodFactory.defaultName];
    [methodFactory configureWithOptions:factoryOptions unknownOptionHandler:[self unknownOptionHandlerForObjectFactory:methodFactory]];

    return methodFactory;
}

-(void) objectFactory:(ALCClassObjectFactory *) objectFactory initializer:(SEL) initializer, ... {

    [ALCRuntime validateClass:objectFactory.objectClass selector:initializer];

    alc_loadVarArgsAfterVariableIntoArray(initializer, unknownArguments);

    NSArray<id<ALCDependency>> *arguments = [unknownArguments methodArgumentsWithUnknownArgumentHandler:^(id argument) {
        throwException(@"AlchemicIllegalArgument", @"Expected a argument definition, search criteria or constant. Got: %@", argument);
    }];

    __unused id _ = [[ALCClassObjectFactoryInitializer alloc] initWithObjectFactory:objectFactory
                                                                        initializer:initializer
                                                                               args:arguments];
}

-(void) objectFactory:(ALCClassObjectFactory *) objectFactory vaiableInjection:(NSString *) variable, ... {

    STLog(objectFactory.objectClass, @"Register injection %@.%@", NSStringFromClass(objectFactory.objectClass), variable);

    alc_loadVarArgsAfterVariableIntoArray(variable, valueArguments);

    Ivar ivar = [ALCRuntime aClass:objectFactory.objectClass variableForInjectionPoint:variable];
    Class varClass = [ALCRuntime typeDataForIVar:ivar].objcClass;
    [objectFactory registerDependency:[valueArguments dependencyWithClass:varClass] forVariable:ivar withName:variable];
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
    return dependency.searchResult;
}

#pragma mark - Internal

-(void (^)(id option)) unknownOptionHandlerForObjectFactory:(id<ALCObjectFactory>) objectFactory {
    return ^(id option) {
        if ([(NSObject *) option isKindOfClass:[ALCWithName class]]) {
            [self->_model objectFactory:objectFactory
                            changedName:objectFactory.defaultName
                                newName:((ALCWithName *) option).asName];
        } else {
            throwException(@"AlchemicIllegalArgument", @"Expected a factory config macro");
        }
    };
}

@end

NS_ASSUME_NONNULL_END
