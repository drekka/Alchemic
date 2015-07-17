//
//  ALCMacroArgumentProcessor.m
//  Alchemic
//
//  Created by Derek Clarkson on 15/07/2015.
//  Copyright © 2015 Derek Clarkson. All rights reserved.
//

@import ObjectiveC;

#import "ALCMethodRegistrationMacroProcessor.h"
#import <Alchemic/Alchemic.h>

NS_ASSUME_NONNULL_BEGIN

@implementation ALCMethodRegistrationMacroProcessor {
    NSMutableArray *_valueSourceMacros;
}

-(instancetype) initWithParentClass:(Class) parentClass selector:(SEL) selector returnType:(Class) returnType {
    self = [super initWithParentClass:parentClass];
    if (self) {
        _selector = selector;
        _returnType = returnType;
        _valueSourceMacros = [[NSMutableArray alloc] init];
    }
    return self;
}

-(void) addArgument:(id) argument {

    if ([argument isKindOfClass:[ALCIsFactory class]]) {
        _isFactory = YES;
    } else if ([argument isKindOfClass:[ALCAsName class]]) {
        _asName = ((ALCAsName *)argument).asName;
    } else if ([argument isKindOfClass:[ALCIsPrimary class]]) {
        _isPrimary = YES;
    } else if ([argument isKindOfClass:[ALCQualifier class]]
               || [argument isKindOfClass:[NSArray class]]
               || [argument isKindOfClass:[ALCConstantValue class]]) {
        [_valueSourceMacros addObject:(id<ALCModelSearchExpression>)argument];
    } else {
        [super addArgument:argument];
    }
}

-(NSArray<id<ALCValueSource>> *) methodValueSources {
    NSMutableArray *valueSources = [[NSMutableArray alloc] initWithCapacity:[_valueSourceMacros count]];
    [_valueSourceMacros enumerateObjectsUsingBlock:^(id  __nonnull macros, NSUInteger idx, BOOL * __nonnull stop) {
        [valueSources addObject:[self valueSourceForMacros:[macros isKindOfClass:[NSArray class]] ? macros : @[macros]]];
    }];
    return valueSources;
}

-(void) validate {
    // Setup the name.
    if (_asName == nil) {
        _asName = [NSString stringWithFormat:@"%@::%@", NSStringFromClass(self.parentClass), NSStringFromSelector(_selector)];
    }

    // Validate the selector and number of arguments.
    if (! class_respondsToSelector(self.parentClass, _selector)) {
        @throw [NSException exceptionWithName:@"AlchemicSelectorNotFound"
                                       reason:[NSString stringWithFormat:@"Failed to find selector -[%s %s]", class_getName(self.parentClass), sel_getName(_selector)]
                                     userInfo:nil];
    }


    // Locate the method.
    Method method = class_getInstanceMethod(self.parentClass, _selector);
    if (method == NULL) {
        _isClassSelector = YES;
        method = class_getClassMethod(self.parentClass, _selector);
    }

    // Validate the number of arguments.
    unsigned long nbrArgs = method_getNumberOfArguments(method) - 2;
    if (nbrArgs != [_valueSourceMacros count]) {
        @throw [NSException exceptionWithName:@"AlchemicIncorrectNumberArguments"
                                       reason:[NSString stringWithFormat:@"-[%s %s] - Expecting %lu argument matchers, got %lu",
                                               class_getName(self.parentClass),
                                               sel_getName(_selector),
                                               nbrArgs,
                                               (unsigned long)[_valueSourceMacros count]]
                                     userInfo:nil];
    }
}

@end

NS_ASSUME_NONNULL_END
