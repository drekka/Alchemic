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
#import "ALCModelDependency.h"
#import "ALCArgument.h"
#import "ALCInternalMacros.h"

NS_ASSUME_NONNULL_BEGIN

@implementation NSArray (Alchemic)

-(NSArray<id<ALCDependency>> *) methodArgumentsWithUnexpectedTypeHandler:(nullable void (^)(id argument)) unexpectedTypeHandler {

    NSMutableArray<id<ALCDependency>> *arguments = [[NSMutableArray alloc] initWithCapacity:self.count];

    for (id argumentDef in self) {

        if ([argumentDef isKindOfClass:[ALCArgument class]]) {
            [arguments addObject:((ALCArgument *) argumentDef).dependency];

        } else if ([argumentDef isKindOfClass:[ALCModelSearchCriteria class]]) {
            ALCModelSearchCriteria *criteria = argumentDef;
            id<ALCDependency> modelSearch = [[ALCModelDependency alloc] initWithObjectClass:[NSObject class] criteria:criteria];
            [arguments addObject:modelSearch];

        } else if ([argumentDef conformsToProtocol:@protocol(ALCDependency)]) {
            [arguments addObject:argumentDef];

        } else {
            if (unexpectedTypeHandler) {
                unexpectedTypeHandler(argumentDef);
            } else {
                throwException(@"AlchemicIllegalArgument", @"Expected a argument definition, search criteria or constant. Got: %@", argumentDef);
            }
        }
    }

    return arguments;
}

-(id<ALCDependency>) dependencyWithClass:(Class) dependencyClass {

    __block ALCModelSearchCriteria *searchCriteria;
    __block id<ALCDependency> constant;

    for (id criteria in self) {

        if ([criteria isKindOfClass:[ALCModelSearchCriteria class]]) {

            if (constant) {
                throwException(@"AlchemicIllegalArgument", @"You cannot combine model search criteria and constants.");
            }
            searchCriteria = searchCriteria ? [searchCriteria combineWithCriteria:criteria] : criteria;

        } else if ([criteria conformsToProtocol:@protocol(ALCConstant)]) {

            if (searchCriteria) {
                throwException(@"AlchemicIllegalArgument", @"You cannot combine model search criteria and constants.");
            }
            constant = criteria;

        } else {
            throwException(@"AlchemicIllegalArgument", @"Expected a search criteria or constant. Got: %@", criteria);
        }
        
    }

    // Default to the dependency class if no constant or criteria provided.
    if (!constant && !searchCriteria) {
        searchCriteria = [ALCModelSearchCriteria searchCriteriaForClass:dependencyClass];
    }

    return constant ? constant : [[ALCModelDependency alloc] initWithObjectClass:dependencyClass
                                                                        criteria:searchCriteria];
}

-(nullable ALCSimpleBlock) combineBlocks {
    if (self.count == 0) {
        return NULL;
    }
    return ^{
        for (ALCSimpleBlock block in self) {
            block();
        }
    };
}

@end

NS_ASSUME_NONNULL_END
