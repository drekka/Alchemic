//
//  ALCMethodArgMacroProcessor.m
//  Alchemic
//
//  Created by Derek Clarkson on 18/07/2015.
//  Copyright © 2015 Derek Clarkson. All rights reserved.
//

@import ObjectiveC;
#import <StoryTeller/StoryTeller.h>

#import "ALCMacroProcessor.h"

#import "ALCValueSourceFactory.h"
#import "ALCModelSearchExpression.h"
#import "ALCMacro.h"
#import "ALCIsFactory.h"
#import "ALCWithName.h"
#import "ALCIsPrimary.h"
#import "ALCConstantValue.h"
#import "ALCIsExternal.h"

NS_ASSUME_NONNULL_BEGIN

@implementation ALCMacroProcessor {
    NSUInteger _allowedMacros;
    NSMutableArray<ALCValueSourceFactory *> *_valueSourceFactories;
}

-(instancetype) initWithAllowedMacros:(NSUInteger) allowedMacros {
    self = [super init];
    if (self) {
        _allowedMacros = allowedMacros;
        _valueSourceFactories = [[NSMutableArray alloc] init];
    }
    return self;
}

-(void) configureAsAppDelegate {
    _valueSourceFactories = [[NSMutableArray alloc] init];
    _isExternal = YES;
    _isFactory = NO;
    _isPrimary = NO;
}

-(void) addMacro:(id<ALCMacro>) macro {

    if (macro == [ALCIsFactory factoryMacro] && _allowedMacros & ALCAllowedMacrosFactory) {
        _isFactory = YES;

    } else if ([macro isKindOfClass:[ALCWithName class]] && _allowedMacros & ALCAllowedMacrosName) {
        _asName = ((ALCWithName *)macro).asName;

    } else if (macro == [ALCIsPrimary primaryMacro] && _allowedMacros & ALCAllowedMacrosPrimary) {
        _isPrimary = YES;

    } else if (macro == [ALCIsExternal externalMacro] && _allowedMacros & ALCAllowedMacrosExternal) {
        _isExternal = YES;

    } else if ([macro isKindOfClass:[ALCValueSourceFactory class]] && _allowedMacros & ALCAllowedMacrosArg) {
        [_valueSourceFactories addObject:(ALCValueSourceFactory *)macro];

    } else {
        @throw [NSException exceptionWithName:@"AlchemicUnexpectedMacro"
                                       reason:[NSString stringWithFormat:@"Unexpected macro %@", macro]
                                     userInfo:nil];
    }
}

-(id<ALCValueSource>) valueSourceAtIndex:(NSUInteger) index {
    return _valueSourceFactories[index].valueSource;
}

-(NSUInteger) valueSourceCount {
    return [_valueSourceFactories count];
}

-(NSString *)description {
    NSMutableArray *flags = [[NSMutableArray alloc] init];
    if (self.isFactory) {
        [flags addObject:@"factory"];
    }
    if (self.isPrimary) {
        [flags addObject:@"primary"];
    }
    if (self.isExternal) {
        [flags addObject:@"external"];
    }
    if (self.asName != nil) {
        [flags addObject:[NSString stringWithFormat:@"name: '%@'", self.asName]];
    }
    if ([self valueSourceCount] > 0u) {
        [flags addObject:[_valueSourceFactories componentsJoinedByString:@", "]];
    }
    return [NSString stringWithFormat:@"Macro processor: %@", [flags componentsJoinedByString:@", "]];
}

@end

NS_ASSUME_NONNULL_END
