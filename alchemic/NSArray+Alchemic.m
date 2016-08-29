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

NS_ASSUME_NONNULL_BEGIN

@implementation NSArray (Alchemic)

#pragma mark - Argument scanning

-(NSArray<id<ALCDependency>> *) methodArgumentsWithTypes:(NSArray<ALCType *> *) types
                                  unknownArgumentHandler:(void (^)(id argument)) unknownArgumentHandler {

    NSMutableArray<id<ALCDependency>> *arguments = [[NSMutableArray alloc] init];

    NSUInteger nextIdx = 0;
    for (id nextArgument in self) {

        // Already built method arguments are added as is.
        ALCMethodArgumentDependency *dependency;
        if ([nextArgument isKindOfClass:[ALCMethodArgumentDependency class]]) {
            dependency = nextArgument;

            // Search criteria and constants are assumed to return a NSObject
        } else if ([nextArgument isKindOfClass:[ALCModelSearchCriteria class]]) {
            ALCType *modelSearchType = [ALCType typeWithClass:[NSObject class]];
            id<ALCValueSource> source = [[ALCModelValueSource alloc] initWithType:modelSearchType criteria:nextArgument];
            dependency = [ALCMethodArgumentDependency argumentWithType:types[nextIdx] valueSource:source];

        } else if ([nextArgument conformsToProtocol:@protocol(ALCValueSource)]) {
            id<ALCValueSource> source = nextArgument;
            dependency = [ALCMethodArgumentDependency argumentWithType:source.type valueSource:source];
        }

        if (dependency) {
            dependency.index = nextIdx++;
            [arguments addObject:dependency];
        } else {
            unknownArgumentHandler(nextArgument);
        }
    };

    return arguments;
}

-(nullable ALCModelSearchCriteria *) modelSearchCriteriaWithUnknownArgumentHandler:(void (^)(id argument)) unknownArgumentHandler {

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
