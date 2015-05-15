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
#import "ALCLogger.h"

@implementation ALCFactoryMethod {
    __weak ALCInstance *_factoryInstance;
    SEL _factorySelector;
    NSInvocation *_factoryInvocation;
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
        
        // Setup the dependencies for each argument.
        Class arrayClass = [NSArray class];
        [argumentMatchers enumerateObjectsUsingBlock:^(id matchers, NSUInteger idx, BOOL *stop) {
            NSSet *matcherSet = object_isClass(arrayClass) ? [NSSet setWithArray:matchers] : [NSSet setWithObject:matchers];
            [self addDependencyResolver:[[ALCMethodArgumentDependency alloc] initWithFactoryMethod:self
                                                                                     argumentIndex:(int) idx
                                                                                          matchers:matcherSet]];
        }];
        
    }
    return self;
}

-(id) object {

    logCreation(@"Creating object with %@", [self description]);
    
    id factoryObject = _factoryInstance.object;
    
    // Get an invocation ready.
    if (_factoryInvocation == nil) {
        NSMethodSignature *sig = [factoryObject methodSignatureForSelector:_factorySelector];
        _factoryInvocation = [NSInvocation invocationWithMethodSignature:sig];
        _factoryInvocation.selector = _factorySelector;
    }

    // Load the arguments.
    [self resolveDependencies];
    [self.dependencies enumerateObjectsUsingBlock:^(ALCResolver *resolver, NSUInteger idx, BOOL *stop) {
        NSSet *candidates = resolver.candidateInstances;
    }];
    
    [_factoryInvocation invokeWithTarget:factoryObject];

    id returnObj;
    [_factoryInvocation getReturnValue:&returnObj];
    return returnObj;

}

-(NSString *) description {
    return [NSString stringWithFormat:@"factory method %s::%s -> %s", class_getName(_factoryInstance.objectClass), sel_getName(_factorySelector), class_getName(self.objectClass)];
}

@end
