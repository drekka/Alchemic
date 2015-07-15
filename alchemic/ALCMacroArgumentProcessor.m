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

NS_ASSUME_NONNULL_BEGIN

@implementation ALCMacroArgumentProcessor {
    NSMutableArray *_searchArguments;
}

-(instancetype) init {
    self = [super init];
    if (self) {
        _selector = NULL;
        _searchArguments = [[NSMutableArray alloc] init];
    }
    return self;
}

-(void) processArgument:(id) argument {

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
    } else if ([argument isKindOfClass:[ALCConstantValue class]]) {
        _constantValue = ((ALCConstantValue *)argument).value;
    } else if ([argument isKindOfClass:[ALCIsPrimary class]]) {
        _isPrimary = YES;
    } else if ([argument isKindOfClass:[ALCQualifier class]]
               || [argument isKindOfClass:[NSArray class]]) {
        [_searchArguments addObject:(id<ALCModelSearchExpression>)argument];
    }
}

-(NSSet<id<ALCModelSearchExpression>> *) searchExpressions {
    return [NSSet setWithArray:_searchArguments];
}

-(NSSet<id<ALCModelSearchExpression>> *) searchExpressionsAtIndex:(NSUInteger) index {
    return _searchArguments[index];
}

-(void) validateWithClass:(Class) parentClass {
    if (_selector == nil) {
        [self validateDependencyInfo];
    } else {
        [self validateMethodInfoForClass:parentClass];
    }
}

-(void) validateDependencyInfo {
    // all arguments must be expressions.
    [_searchArguments enumerateObjectsUsingBlock:^(id  __nonnull searchArgument, NSUInteger idx, BOOL * __nonnull stop) {
        if (![searchArgument conformsToProtocol:@protocol(ALCModelSearchExpression)]) {
            @throw [NSException exceptionWithName:@"AlchemicUnexpectedArray"
                                           reason:[NSString stringWithFormat:@"Arrays of qualifiers not allowed for dependencies. Check the definition of %@", self->_variableName]
                                         userInfo:nil];
        }
    }];
}

-(void) validateMethodInfoForClass:(Class) parentClass {

    // Wrap all arguments in NSSets.
    [_searchArguments enumerateObjectsUsingBlock:^(id  __nonnull searchArgument, NSUInteger idx, BOOL * __nonnull stop) {
        self->_searchArguments[idx] = [searchArgument conformsToProtocol:@protocol(ALCModelSearchExpression)] ? [NSSet setWithObject:searchArgument] : [NSSet setWithArray:searchArgument];
    }];

    // Validate the selector and number of arguments.
    if (! class_respondsToSelector(parentClass, _selector)) {
        @throw [NSException exceptionWithName:@"AlchemicSelectorNotFound"
                                       reason:[NSString stringWithFormat:@"Faciled to find selector -[%s %s]", class_getName(parentClass), sel_getName(_selector)]
                                     userInfo:nil];
    }


    // Locate the method.
    Method method = class_getInstanceMethod(parentClass, _selector);
    if (method == NULL) {
        _isClassSelector = YES;
        method = class_getClassMethod(parentClass, _selector);
    }

    // Validate the number of arguments.
    unsigned long nbrArgs = method_getNumberOfArguments(method) - 2;
    if (nbrArgs != [_searchArguments count]) {
        @throw [NSException exceptionWithName:@"AlchemicIncorrectNumberArguments"
                                       reason:[NSString stringWithFormat:@"-[%s %s] - Expecting %lu argument matchers, got %lu",
                                               class_getName(parentClass),
                                               sel_getName(_selector),
                                               nbrArgs,
                                               (unsigned long)[_searchArguments count]]
                                     userInfo:nil];
    }

}

@end

NS_ASSUME_NONNULL_END
