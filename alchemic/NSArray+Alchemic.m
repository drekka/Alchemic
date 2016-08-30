//
//  NSArray+Alchemic.m
//  Alchemic
//
//  Created by Derek Clarkson on 22/03/2016.
//  Copyright © 2016 Derek Clarkson. All rights reserved.
//

#import "NSArray+Alchemic.h"

#import "ALCDependency.h"
#import "ALCModelSearchCriteria.h"
#import "ALCConstant.h"
#import "ALCModelValueSource.h"
#import "ALCMethodArgumentDependency.h"
#import "ALCMacros.h"
#import "ALCInternalMacros.h"
#import "ALCException.h"
#import <Alchemic/ALCType.h>
#import <Alchemic/ALCValueSource.h>
#import <Alchemic/ALCArrayValueSource.h>

NS_ASSUME_NONNULL_BEGIN

@implementation NSArray (Alchemic)

#pragma mark - Argument scanning

-(NSArray<id<ALCDependency>> *) methodArgumentsWithExpectedTypes:(NSArray<ALCType *> *) types
                                                 unknownArgument:(void (^)(id argument)) otherArgumentHandler {
    
    NSMutableArray<id<ALCDependency>> *arguments = [[NSMutableArray alloc] init];
    
    NSUInteger nextIdx = 0;
    for (id nextArgument in self) {
        
        // Already built method arguments are added as is.
        ALCMethodArgumentDependency *dependency;
        if ([nextArgument isKindOfClass:[ALCMethodArgumentDependency class]]) {
            dependency = nextArgument;
            
        } else if ([nextArgument isKindOfClass:[ALCModelSearchCriteria class]]) {
            
            // Raw search criteria are expected to represent a single argument.
            ALCType *modelSearchType = [ALCType typeWithClass:[NSObject class]];
            id<ALCValueSource> source = [ALCModelValueSource valueSourceWithType:modelSearchType criteria:nextArgument];
            dependency = [ALCMethodArgumentDependency dependencyWithType:types[nextIdx] valueSource:source];
            
        } else if ([nextArgument conformsToProtocol:@protocol(ALCValueSource)]) {
            
            // FInally check for a constant value which gets a similar treatment.
            id<ALCValueSource> source = nextArgument;
            dependency = [ALCMethodArgumentDependency dependencyWithType:types[nextIdx] valueSource:source];
        }
        
        // If we have a dependency then add it to the results.
        if (dependency) {
            dependency.index = nextIdx++;
            [arguments addObject:dependency];
            
        } else {
            // Otherwise add it to the config items.
            otherArgumentHandler(nextArgument);
        }
    };
    
    return arguments;
}

-(nullable id<ALCValueSource>) valueSourceForType:(ALCType *) type
                                 constantsAllowed:(BOOL) constantsAllowed
                                            error:(NSError **) error
                                  unknownArgument:(nullable void (^)(id argument)) otherArgumentHandler {
    
    __block NSMutableArray<id<ALCValueSource>> *constantValues;
    ALCModelSearchCriteria *modelSearchCriteria = [self modelSearchCriteriaWithUnknownArgumentHandler:^(id argument) {
        
        // If the arg is a value source then check if we can accept multiple constants and add to array of constant values.
        if ([argument conformsToProtocol:@protocol(ALCValueSource)]) {
            if (!constantValues) {
                constantValues = [NSMutableArray array];
            }
            [constantValues addObject:argument];
        } else {
            // Otherwise hand it to the handler
            otherArgumentHandler(argument);
        }
    }];
    
    // process constants.
    if (constantValues) {
        if (!constantsAllowed) {
            setError(@"Constant values not allowed");
            return nil;
        }
        if (![type.objcClass isKindOfClass:[NSArray class]] && constantValues.count > 1) {
            setError(@"Multiple constants found");
            return nil;
        }
        if (modelSearchCriteria) {
            setError(@"Cannot specify both constant values and model search criteria");
            return nil;
        }

        if (constantValues.count == 1) {
            return constantValues[0];
        } else {
            return [ALCArrayValueSource valueSourceWithValueSources:constantValues];
        }
    }
    
    return [ALCModelValueSource valueSourceWithType:type criteria:modelSearchCriteria];
}

-(nullable ALCModelSearchCriteria *) modelSearchCriteriaWithDefaultClass:(Class) defaultClass
                                                  unknownArgumentHandler:(void (^)(id argument)) unknownArgumentHandler {
    
    ALCModelSearchCriteria *searchCriteria;
    for (id criteria in self) {
        
        if ([criteria isKindOfClass:[ALCModelSearchCriteria class]]) {
            
            if (searchCriteria) {
                [searchCriteria appendSearchCriteria:criteria];
            } else {
                searchCriteria = criteria;
            }
            
        } else {
            unknownArgumentHandler(criteria);
        }
    }
    
    return searchCriteria;
}

#pragma mark - Resolving

-(void)resolveWithStack:(NSMutableArray<id<ALCResolvable>> *)resolvingStack model:(id<ALCModel>) model {
    [self enumerateObjectsUsingBlock:^(NSObject<ALCDependency> *resolvable, NSUInteger idx, BOOL *stop) {
        [resolvingStack addObject:resolvable];
        [resolvable resolveWithStack:resolvingStack model:model];
        [resolvingStack removeLastObject];
    }];
}

-(BOOL) dependenciesReadyWithCheckingFlag:(BOOL *) checkingFlag {
    
    // If this flag is set then we have looped back to the original variable. So consider everything to be good.
    if (*checkingFlag) {
        return YES;
    }
    
    // Set the checking flag so that we can detect loops.
    *checkingFlag = YES;
    
    for (id<ALCResolvable> resolvable in self) {
        // If a dependency is not ready then we stop checking and return a failure.
        if (!resolvable.isReady) {
            *checkingFlag = NO;
            return NO;
        }
    }
    
    // All dependencies are good to go.
    *checkingFlag = NO;
    return YES;
}

@end

NS_ASSUME_NONNULL_END
