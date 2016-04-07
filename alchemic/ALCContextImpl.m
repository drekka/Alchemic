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
    STLog(self, @"\n%@", _model);
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

}

-(ALCMethodObjectFactory *) objectFactory:(ALCClassObjectFactory *) objectFactory
                            factoryMethod:(SEL) selector
                               returnType:(Class) returnType, ... {

    [ALCRuntime validateClass:objectFactory.objectClass selector:selector];

    NSMutableArray *unknownArguments = [[NSMutableArray alloc] init];
    alc_loadVarArgsAfterVariableIntoArray(returnType, unknownArguments);
    NSArray<id<ALCDependency>> *arguments = [unknownArguments methodArgumentsWithUnexpectedTypeHandler:^(id argument) {

    }];

    ALCMethodObjectFactory *methodFactory = [[ALCMethodObjectFactory alloc] initWithClass:(Class) returnType
                                                                      parentObjectFactory:objectFactory
                                                                                 selector:selector
                                                                                     args:arguments];
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
