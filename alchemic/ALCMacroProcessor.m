//
//  ALCMethodArgMacroProcessor.m
//  Alchemic
//
//  Created by Derek Clarkson on 18/07/2015.
//  Copyright © 2015 Derek Clarkson. All rights reserved.
//

#import "ALCMacroProcessor.h"

#import "ALCValueSource.h"
#import "ALCModelSearchExpression.h"
#import "ALCConstantValue.h"
#import "ALCConstantValueSource.h"
#import "ALCModelValueSource.h"

NS_ASSUME_NONNULL_BEGIN

@implementation ALCMacroProcessor

-(instancetype) init {
    self = [super init];
    if (self) {
        _valueSourceMacros = [[NSMutableArray alloc] init];
    }
    return self;
}

-(instancetype)initWithParentClass:(Class)parentClass {
    self = [self init];
    if (self) {
        _parentClass = parentClass;
    }
    return self;
}

-(void) addArgument:(id) argument {
    if ([argument conformsToProtocol:@protocol(ALCModelSearchExpression)]
        || [argument isKindOfClass:[ALCConstantValue class]]) {
        [_valueSourceMacros addObject:(id<ALCModelSearchExpression>)argument];
    } else {
        NSString *source = self.parentClass == nil ? @"": [NSString stringWithFormat:@" %@ class registration", NSStringFromClass(self.parentClass)];
        @throw [NSException exceptionWithName:@"AlchemicUnexpectedMacro"
                                       reason:[NSString stringWithFormat:@"Unexpected macro %@%@", argument, source]
                                     userInfo:nil];
    }
}

-(id<ALCValueSource>) valueSource {
    return [_valueSourceMacros count] == 0 ? nil : [self valueSourceForMacros:_valueSourceMacros];
}

-(id<ALCValueSource>) valueSourceForMacros:(NSArray *) macros {
    if ([macros[0] isKindOfClass:[ALCConstantValue class]]) {
        return [[ALCConstantValueSource alloc] initWithValue:((ALCConstantValue *)macros[0]).value];
    }
    return [[ALCModelValueSource alloc] initWithSearchExpressions:[NSSet setWithArray:macros]];
}

-(void) validate {

    // Validate arguments.
    for (id macro in _valueSourceMacros) {

        // If any argument is a constant then it must be the only one.
        if ([macro isKindOfClass:[ALCConstantValue class]] && [self->_valueSourceMacros count] > 1) {
            @throw [NSException exceptionWithName:@"AlchemicInvalidArguments"
                                           reason:[NSString stringWithFormat:@"ACValue(...) must be the only data source macro"]
                                         userInfo:nil];
        }

        if ([macro isKindOfClass:[NSArray class]]) {
            @throw [NSException exceptionWithName:@"AlchemicUnexpectedArray"
                                           reason:[NSString stringWithFormat:@"Arrays of qualifiers not allowed for dependencies. Check the definition."]
                                         userInfo:nil];
        }
    };
}

@end

NS_ASSUME_NONNULL_END
