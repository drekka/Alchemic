//
//  ALCVariableDependencyMacroProcessor.m
//  Alchemic
//
//  Created by Derek Clarkson on 17/07/2015.
//  Copyright © 2015 Derek Clarkson. All rights reserved.
//

#import "ALCVariableDependencyMacroProcessor.h"
#import <Alchemic/Alchemic.h>
#import "ALCRuntime.h"

NS_ASSUME_NONNULL_BEGIN

@implementation ALCVariableDependencyMacroProcessor {
    NSMutableArray *_valueSourceMacros;
    NSString *_variableName;
}

-(instancetype) initWithParentClass:(Class) parentClass variable:(NSString *) variable {
    self = [super initWithParentClass:parentClass];
    if (self) {
        _variableName = variable;
        _valueSourceMacros = [[NSMutableArray alloc] init];
    }
    return self;
}

-(void) addArgument:(id) argument {
    if ([argument conformsToProtocol:@protocol(ALCModelSearchExpression)]
        || [argument isKindOfClass:[ALCConstantValue class]]) {
        [_valueSourceMacros addObject:(id<ALCModelSearchExpression>)argument];
    } else {
        [super addArgument:argument];
    }
}

-(id<ALCValueSource>) valueSource {
    return [_valueSourceMacros count] == 0 ? nil : [self valueSourceForMacros:_valueSourceMacros];
}

-(void) validate {
    // Set the ivar.
    _variable = [ALCRuntime aClass:self.parentClass variableForInjectionPoint:_variableName];

    // Check macros
    if ([_valueSourceMacros count] == 0) {
        _valueSourceMacros = [NSMutableArray arrayWithArray:[ALCRuntime searchExpressionsForVariable:_variable].allObjects];
    }

    // Validate arguments.
    for (id macro in _valueSourceMacros) {

        // If any argument is a constant then it must be the only one.
        if ([macro isKindOfClass:[ALCConstantValue class]] && [self->_valueSourceMacros count] > 1) {
            @throw [NSException exceptionWithName:@"AlchemicInvalidArguments"
                                           reason:[NSString stringWithFormat:@"ACValue(...) must be the only data source macro for %@", self->_variableName]
                                         userInfo:nil];
        }

        if ([macro isKindOfClass:[NSArray class]]) {
            @throw [NSException exceptionWithName:@"AlchemicUnexpectedArray"
                                           reason:[NSString stringWithFormat:@"Arrays of qualifiers not allowed for dependencies. Check the definition of %@", self->_variableName]
                                         userInfo:nil];
        }
    };
}

@end

NS_ASSUME_NONNULL_END
