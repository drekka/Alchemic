//
//  ALCFactoryMethod.m
//  alchemic
//
//  Created by Derek Clarkson on 9/05/2015.
//  Copyright (c) 2015 Derek Clarkson. All rights reserved.
//

#import "ALCFactoryMethod.h"
#import "ALCRuntime.h"
#import "ALCInstance.h"
#import "ALCMethodArgumentDependency.h"

@implementation ALCFactoryMethod {
    __weak ALCInstance *_factoryInstance;
    SEL _factorySelector;
    NSMutableArray *_argumentDependencies;
}

-(instancetype) initWithContext:(__weak ALCContext *) context
                factoryInstance:(ALCInstance *) factoryInstance
                factorySelector:(SEL) factorySelector
                     returnType:(Class) returnTypeClass
               argumentMatchers:(NSArray *) argumentMatchers {
    
    self = [super initWithContext:context objectClass:returnTypeClass];
    if (self) {
        
        [ALCRuntime validateSelector:factorySelector withClass:factoryInstance.objectClass];
        
        // Locate the method.
        Method method = class_getInstanceMethod(factoryInstance.objectClass, factorySelector);
        if (method == NULL) {
            method = class_getClassMethod(factoryInstance.objectClass, factorySelector);
        }
        
        // Validate the number of arguments.
        unsigned long nbrArgs = method_getNumberOfArguments(method) - 2;
        if (nbrArgs != [argumentMatchers count]) {
            @throw [NSException exceptionWithName:@"AlchemicIncorrectNumberArguments"
                                           reason:[NSString stringWithFormat:@"%s::%s - Expecting %lu argument matchers, got %lu", object_getClassName(factoryInstance.objectClass), sel_getName(factorySelector), nbrArgs, [argumentMatchers count]]
                                         userInfo:nil];
        }
        
        _factoryInstance = factoryInstance;
        _factorySelector = factorySelector;
        self.name = [NSString stringWithFormat:@"%s::%s", class_getName(factoryInstance.objectClass), sel_getName(factorySelector)];
        
        // Setup the dependencies for each argument.
        _argumentDependencies = [[NSMutableArray alloc] initWithCapacity:[argumentMatchers count]];
        Class arrayClass = [NSArray class];
        [argumentMatchers enumerateObjectsUsingBlock:^(id matchers, NSUInteger idx, BOOL *stop) {
            NSSet *matcherSet = object_isClass(arrayClass) ? [NSSet setWithArray:matchers] : [NSSet setWithObject:matchers];
            ALCMethodArgumentDependency *argumentDependency = [[ALCMethodArgumentDependency alloc] initWithFactoryMethod:self
                                                                                                           argumentIndex:(int) idx
                                                                                                                matchers:matcherSet];
            [_argumentDependencies addObject:argumentDependency];
        }];
        
    }
    return self;
}

-(void) resolveDependencies {
    logDependencyResolving(@"Resolving dependencies for %@", [self description]);
    for (ALCResolver *dependency in _argumentDependencies) {
        [dependency resolveUsingModel:self.context.model];
    }
    
    logRegistration(@"Post processing dependencies for %@", [self description]);
    for (ALCResolver *dependency in _argumentDependencies) {
        [dependency postProcess:self.context.resolverPostProcessors];
    }
}

-(NSString *) description {
    return [NSString stringWithFormat:@"Factory method '%@' %s::%s (%s)", self.name, class_getName(_factoryInstance.objectClass), sel_getName(_factorySelector), class_getName(self.objectClass)];
}

@end
