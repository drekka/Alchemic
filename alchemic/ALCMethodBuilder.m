//
//
//  Created by Derek Clarkson on 9/05/2015.
//  Copyright (c) 2015 Derek Clarkson. All rights reserved.
//

#import <StoryTeller/StoryTeller.h>

#import "ALCMethodBuilder.h"
#import "ALCRuntime.h"
#import "ALCClassBuilder.h"
#import "ALCType.h"
#import <Alchemic/ALCContext.h>

@implementation ALCMethodBuilder {
    ALCClassBuilder *_factoryClassBuilder;
    SEL _factorySelector;
    NSInvocation *_factoryInvocation;
}

-(instancetype) initWithContext:(__weak ALCContext *) context
                      valueType:(ALCType *) valueType
            factoryClassBuilder:(ALCClassBuilder *) factoryClassBuilder
                factorySelector:(SEL) factorySelector
               argumentMatchers:(NSArray<id<ALCMatcher>> *) argumentMatchers {
    
    self = [super initWithContext:context valueType:valueType];
    if (self) {
        
        Class factoryClass = factoryClassBuilder.valueType.typeClass;
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
                                           reason:[NSString stringWithFormat:@"%s::%s - Expecting %lu argument matchers, got %lu", object_getClassName(factoryClassBuilder.valueType.typeClass), sel_getName(factorySelector), nbrArgs, (unsigned long)[argumentMatchers count]]
                                         userInfo:nil];
        }
        
        _factoryClassBuilder = factoryClassBuilder;
        _factorySelector = factorySelector;
        
        // Setup the dependencies for each argument.
        Class arrayClass = [NSArray class];
        [argumentMatchers enumerateObjectsUsingBlock:^(id matchers, NSUInteger idx, BOOL *stop) {
            NSSet<id<ALCMatcher>> *matcherSet = [matchers isKindOfClass:arrayClass] ? [NSSet setWithArray:matchers] : [NSSet setWithObject:matchers];
            [self addDependency:[[ALCDependency alloc] initWithContext:context
                                                             valueType:nil
                                                              matchers:matcherSet]];
        }];
        
    }
    return self;
}

-(id) value {
    id returnValue = super.value;
    if (returnValue == nil) {
        returnValue = [self instantiate];
        ALCContext *strongContext = self.context;
        [strongContext injectDependencies:returnValue];
    }
    return returnValue;
}

-(id) resolveValue {
    
    STLog([self description], @"Creating object with %@", [self description]);
    
    id factoryObject = _factoryClassBuilder.value;
    
    // Get an invocation ready.
    if (_factoryInvocation == nil) {
        NSMethodSignature *sig = [factoryObject methodSignatureForSelector:_factorySelector];
        _factoryInvocation = [NSInvocation invocationWithMethodSignature:sig];
        _factoryInvocation.selector = _factorySelector;
        [_factoryInvocation retainArguments];
    }
    
    // Load the arguments.
    [self.dependencies enumerateObjectsUsingBlock:^(ALCDependency *dependency, NSUInteger idx, BOOL *stop) {
        id argument = dependency.value;
        [self->_factoryInvocation setArgument:&argument atIndex:(NSInteger)idx];
    }];
    
    [_factoryInvocation invokeWithTarget:factoryObject];
    
    id returnObj;
    [_factoryInvocation getReturnValue:&returnObj];
    STLog([self description], @"   Method created a %s", class_getName([returnObj class]));
    return returnObj;
    
}

-(NSString *) description {
    return [NSString stringWithFormat:@"Method builder -(%1$s) %1$s::%2$s", class_getName(_factoryClassBuilder.valueType.typeClass), sel_getName(_factorySelector)];
}

@end
