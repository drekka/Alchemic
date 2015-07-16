//
//  ALCMacroArgumentProcessor.m
//  Alchemic
//
//  Created by Derek Clarkson on 15/07/2015.
//  Copyright © 2015 Derek Clarkson. All rights reserved.
//

@import ObjectiveC;

#import "ALCMacroArgumentProcessor.h"
#import <Alchemic/Alchemic.h>
#import "ALCQualifier+Internal.h"
#import "ALCModelSearchExpression.h"
#import "ALCModelValueSource.h"
#import "ALCConstantValueSource.h"
#import "ALCRuntime.h"

NS_ASSUME_NONNULL_BEGIN

@implementation ALCMacroArgumentProcessor {
    NSMutableArray *_valueSourceMacros;
}

-(instancetype) initWithParentClass:(Class) parentClass {
    self = [super init];
    if (self) {
        _parentClass = parentClass;
        _selector = NULL;
        _valueSourceMacros = [[NSMutableArray alloc] init];
    }
    return self;
}

-(void) addArgument:(id) argument {

    if ([argument isKindOfClass:[ALCIsFactory class]]) {
        _isFactory = YES;
    } else if ([argument isKindOfClass:[ALCAsName class]]) {
        _asName = ((ALCAsName *)argument).asName;
    } else if ([argument isKindOfClass:[ALCIntoVariable class]]) {
        _variableName = ((ALCIntoVariable *)argument).variableName;
    } else if ([argument isKindOfClass:[ALCMethodSelector class]]) {
        _selector = ((ALCMethodSelector *)argument).methodSelector;
    } else if ([argument isKindOfClass:[ALCReturnType class]]) {
        _returnType = ((ALCReturnType *)argument).returnType;
    } else if ([argument isKindOfClass:[ALCIsPrimary class]]) {
        _isPrimary = YES;
    } else if ([argument isKindOfClass:[ALCQualifier class]]
               || [argument isKindOfClass:[NSArray class]]
               || [argument isKindOfClass:[ALCConstantValue class]]) {
        [_valueSourceMacros addObject:(id<ALCModelSearchExpression>)argument];
    }
}

-(id<ALCValueSource>)dependencyValueSource {
    return [_valueSourceMacros count] == 0 ? nil : [self valueSourceForMacros:_valueSourceMacros];
}

-(NSArray<id<ALCValueSource>> *) methodValueSources {
    NSMutableArray *valueSources = [[NSMutableArray alloc] initWithCapacity:[_valueSourceMacros count]];
    [_valueSourceMacros enumerateObjectsUsingBlock:^(id  __nonnull macros, NSUInteger idx, BOOL * __nonnull stop) {
        [valueSources addObject:[self valueSourceForMacros:[macros isKindOfClass:[NSArray class]] ? macros : @[macros]]];
    }];
    return valueSources;
}

-(void) validate {
    if (_variableName == nil && _selector == NULL) {
        [self validateClassRegistrationInfo];
    } else {
        if (_selector == nil) {
            [self validateDependencyInfo];
        } else {
            [self validateMethodInfo];
        }
    }
}

#pragma mark - Internal

-(void) validateClassRegistrationInfo {

    // Setup the name.
    if (_asName == nil) {
        _asName = NSStringFromClass(_parentClass);
    }

    if ([_valueSourceMacros count] > 0) {
        @throw [NSException exceptionWithName:@"AlchemicInvalidRegistration"
                                       reason:[NSString stringWithFormat:@"Cannot specify search arguments with a class registration for %@", NSStringFromClass(_parentClass)]
                                     userInfo:nil];
    }
}

-(void) validateDependencyInfo {

    // Set the ivar.
    _variable = [ALCRuntime aClass:_parentClass variableForInjectionPoint:_variableName];

    // Check macros
    if ([_valueSourceMacros count] == 0) {
        _valueSourceMacros = [NSMutableArray arrayWithArray:[ALCRuntime qualifiersForVariable:_variable].allObjects];
    }

    // Validate arguments.
    for (id macro in _valueSourceMacros) {

        // If any argument is a constant then it must be the only one.
        if ([macro isKindOfClass:[ALCConstantValue class]] && [self->_valueSourceMacros count] > 1) {
            @throw [NSException exceptionWithName:@"AlchemicInvalidArguments"
                                           reason:[NSString stringWithFormat:@"ACWithValue(...) must be the only data source macro for %@", self->_variableName]
                                         userInfo:nil];
        }

        if ([macro isKindOfClass:[NSArray class]]) {
            @throw [NSException exceptionWithName:@"AlchemicUnexpectedArray"
                                           reason:[NSString stringWithFormat:@"Arrays of qualifiers not allowed for dependencies. Check the definition of %@", self->_variableName]
                                         userInfo:nil];
        }
    };
}

-(void) validateMethodInfo {

    // Setup the name.
    if (_asName == nil) {
        _asName = [NSString stringWithFormat:@"%@::%@", NSStringFromClass(_parentClass), NSStringFromSelector(_selector)];
    }

    // Validate the selector and number of arguments.
    if (! class_respondsToSelector(_parentClass, _selector)) {
        @throw [NSException exceptionWithName:@"AlchemicSelectorNotFound"
                                       reason:[NSString stringWithFormat:@"Failed to find selector -[%s %s]", class_getName(_parentClass), sel_getName(_selector)]
                                     userInfo:nil];
    }


    // Locate the method.
    Method method = class_getInstanceMethod(_parentClass, _selector);
    if (method == NULL) {
        _isClassSelector = YES;
        method = class_getClassMethod(_parentClass, _selector);
    }

    // Validate the number of arguments.
    unsigned long nbrArgs = method_getNumberOfArguments(method) - 2;
    if (nbrArgs != [_valueSourceMacros count]) {
        @throw [NSException exceptionWithName:@"AlchemicIncorrectNumberArguments"
                                       reason:[NSString stringWithFormat:@"-[%s %s] - Expecting %lu argument matchers, got %lu",
                                               class_getName(_parentClass),
                                               sel_getName(_selector),
                                               nbrArgs,
                                               (unsigned long)[_valueSourceMacros count]]
                                     userInfo:nil];
    }

}

-(id<ALCValueSource>) valueSourceForMacros:(NSArray *) macros {
    if ([macros[0] isKindOfClass:[ALCConstantValue class]]) {
        return [[ALCConstantValueSource alloc] initWithValue:((ALCConstantValue *)macros[0]).value];
    }
    return [[ALCModelValueSource alloc] initWithSearchExpressions:[NSSet setWithArray:macros]];
}

@end

NS_ASSUME_NONNULL_END
