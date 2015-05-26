//
//  ALCFactoryMethod.m
//  alchemic
//
//  Created by Derek Clarkson on 9/05/2015.
//  Copyright (c) 2015 Derek Clarkson. All rights reserved.
//

#import "ALCFactoryMethodBuilder.h"
#import "ALCRuntime.h"
#import "ALCClassBuilder.h"
#import "ALCLogger.h"
#import "ALCType.h"

@implementation ALCFactoryMethodBuilder {
    ALCClassBuilder *_factoryClassBuilder;
    SEL _factorySelector;
    NSInvocation *_factoryInvocation;
}

-(instancetype) initWithContext:(__weak ALCContext *) context
                      valueType:(ALCType *) valueType
            factoryClassBuilder:(ALCClassBuilder *) factoryClassBuilder
                factorySelector:(SEL) factorySelector
               argumentMatchers:(NSArray *) argumentMatchers {
    
    self = [super initWithContext:context valueType:valueType];
    if (self) {
        
        Class factoryClass = object_getClass(factoryClassBuilder);
        [ALCRuntime validateSelector:factorySelector withClass:factoryClass];
        
        // Locate the method.
        Method method = class_getInstanceMethod(factoryClass, factorySelector);
        if (method == NULL) {
            method = class_getClassMethod(factoryClass, factorySelector);
        }
        
        // Validate the number of arguments.
        unsigned long nbrArgs = method_getNumberOfArguments(method) - 2;
        if (nbrArgs != [argumentMatchers count]) {
            @throw [NSException exceptionWithName:@"AlchemicIncorrectNumberArguments"
                                           reason:[NSString stringWithFormat:@"%s::%s - Expecting %lu argument matchers, got %lu", object_getClassName(factoryClassBuilder.valueType.typeClass), sel_getName(factorySelector), nbrArgs, [argumentMatchers count]]
                                         userInfo:nil];
        }
        
        _factoryClassBuilder = factoryClassBuilder;
        _factorySelector = factorySelector;
        
        // Setup the dependencies for each argument.
        Class arrayClass = [NSArray class];
        [argumentMatchers enumerateObjectsUsingBlock:^(id matchers, NSUInteger idx, BOOL *stop) {
            NSSet *matcherSet = object_isClass(arrayClass) ? [NSSet setWithArray:matchers] : [NSSet setWithObject:matchers];
            [self addDependency:[[ALCDependency alloc] initWithContext:context
                                                             valueType:nil
                                                              matchers:matcherSet]];
        }];
        
    }
    return self;
}

-(id) value {
    
    logCreation(@"Creating object with %@", [self description]);
    
    id factoryObject = _factoryClassBuilder.value;
    
    // Get an invocation ready.
    if (_factoryInvocation == nil) {
        NSMethodSignature *sig = [factoryObject methodSignatureForSelector:_factorySelector];
        _factoryInvocation = [NSInvocation invocationWithMethodSignature:sig];
        _factoryInvocation.selector = _factorySelector;
    }
    
    // Load the arguments.
    [self.dependencies enumerateObjectsUsingBlock:^(ALCDependency *dependency, NSUInteger idx, BOOL *stop) {
        id argument = dependency.value;
        [_factoryInvocation setArgument:&argument atIndex:idx];
    }];
    
    [_factoryInvocation invokeWithTarget:factoryObject];
    
    id returnObj;
    [_factoryInvocation getReturnValue:&returnObj];
    return returnObj;
    
}

-(NSString *) description {
    return [NSString stringWithFormat:@"method -(%1$s)%1$s::%2$s", class_getName(_factoryClassBuilder.valueType.typeClass), sel_getName(_factorySelector)];
}

@end
