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
#import "ALCModelInjection.h"
#import "ALCMethodArgument.h"
#import "ALCInternalMacros.h"

NS_ASSUME_NONNULL_BEGIN

@implementation NSArray (Alchemic)

-(NSArray<id<ALCDependency>> *) methodArgumentsWithUnknownArgumentHandler:(void (^)(id argument)) unknownArgumentHandler {
    
    NSMutableArray<id<ALCDependency>> *arguments = [[NSMutableArray alloc] initWithCapacity:self.count];
    
    [self enumerateObjectsUsingBlock:^(id nextArgument, NSUInteger idx, BOOL * _Nonnull stop) {

        ALCMethodArgument *methodArgument = nil;
        
        if ([nextArgument isKindOfClass:[ALCMethodArgument class]]) {
            methodArgument = (ALCMethodArgument *) nextArgument;

        } else if ([nextArgument isKindOfClass:[ALCModelSearchCriteria class]]) {
            ALCModelSearchCriteria *criteria = nextArgument;
            id<ALCInjection> modelSearch = [[ALCModelInjection alloc] initWithObjectClass:[NSObject class] criteria:criteria];
            methodArgument = [ALCMethodArgument argumentWithClass:[NSObject class] criteria:modelSearch, nil];
            
        } else if ([nextArgument conformsToProtocol:@protocol(ALCConstant)]) {
            methodArgument = [ALCMethodArgument argumentWithClass:[NSObject class] criteria:nextArgument, nil];
        }

        if (methodArgument) {
            methodArgument.index = (int) idx;
            [arguments addObject:nextArgument];
        } else {
            unknownArgumentHandler(nextArgument);
        }
    }];
    
    return arguments;
}

-(id<ALCInjection>) injectionWithClass:(Class) injectionClass allowConstants:(BOOL) allowConstants {
    
    __block ALCModelSearchCriteria *searchCriteria;
    __block id<ALCInjection> constant;
    
    for (id criteria in self) {
        
        if ([criteria isKindOfClass:[ALCModelSearchCriteria class]]) {
            
            if (constant) {
                throwException(@"AlchemicIllegalArgument", nil, @"You cannot combine model search criteria and constants.");
            }
            searchCriteria = searchCriteria ? [searchCriteria combineWithCriteria:criteria] : criteria;
            
        } else if ([criteria conformsToProtocol:@protocol(ALCConstant)]) {
            
            if (!allowConstants) {
                throwException(@"AlchemicIllegalArgument", nil, @"Expected a search criteria or constant. Got: %@", criteria);
            }
            
            if (searchCriteria) {
                throwException(@"AlchemicIllegalArgument", nil, @"You cannot combine model search criteria and constants.");
            }
            constant = criteria;
            
        } else {
            throwException(@"AlchemicIllegalArgument", nil, @"Expected a search criteria or constant. Got: %@", criteria);
        }
        
    }
    
    // Default to the dependency class if no constant or criteria provided.
    if (!constant && !searchCriteria) {
        searchCriteria = [ALCModelSearchCriteria searchCriteriaForClass:injectionClass];
    }
    
    return constant ? constant : [[ALCModelInjection alloc] initWithObjectClass:injectionClass
                                                                       criteria:searchCriteria];
}

-(nullable ALCSimpleBlock) combineSimpleBlocks {
    return self.count == 0 ? NULL : ^{
        for (ALCSimpleBlock block in self) {
            block();
        }
    };
}

-(void)resolveArgumentsWithStack:(NSMutableArray<id<ALCResolvable>> *)resolvingStack model:(id<ALCModel>) model {
    [self enumerateObjectsUsingBlock:^(NSObject<ALCDependency> *argument, NSUInteger idx, BOOL *stop) {
        [resolvingStack addObject:argument];
        [argument resolveWithStack:resolvingStack model:model];
        [resolvingStack removeLastObject];
    }];
}

@end

NS_ASSUME_NONNULL_END
