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
    NSMutableArray<ALCArg *> *_args;
}

-(instancetype) initWithParentClass:(Class) parentClass selector:(SEL) selector returnType:(Class) returnType {
    self = [super initWithParentClass:parentClass];
    if (self) {
        _selector = selector;
        _returnType = returnType;
        _args = [[NSMutableArray alloc] init];
    }
    return self;
}

-(void) addArgument:(id) argument {

    if ([argument isKindOfClass:[ALCIsFactory class]]) {
        _isFactory = YES;
    } else if ([argument isKindOfClass:[ALCWithName class]]) {
        _asName = ((ALCWithName *)argument).asName;
    } else if ([argument isKindOfClass:[ALCIsPrimary class]]) {
        _isPrimary = YES;
    } else if ([argument isKindOfClass:[ALCArg class]]) {
        [_args addObject:argument];
    } else {
        [super addArgument:nil];
    }
}

-(NSArray<ALCArg *> *) methodValueSources {
    return _args;
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
    if (nbrArgs != [_args count]) {
        @throw [NSException exceptionWithName:@"AlchemicIncorrectNumberArguments"
                                       reason:[NSString stringWithFormat:@"-[%s %s] - Expecting %lu argument matchers, got %lu",
                                               class_getName(self.parentClass),
                                               sel_getName(_selector),
                                               nbrArgs,
                                               (unsigned long)[_args count]]
                                     userInfo:nil];
    }

    [super validate];
}

@end

NS_ASSUME_NONNULL_END
