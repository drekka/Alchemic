//
//  NSArray+Alchemic.m
//  Alchemic
//
//  Created by Derek Clarkson on 22/03/2016.
//  Copyright © 2016 Derek Clarkson. All rights reserved.
//

#import <Alchemic/NSArray+Alchemic.h>

#import <Alchemic/ALCDependency.h>
#import <Alchemic/ALCModelSearchCriteria.h>
#import <Alchemic/ALCConstant.h>
#import <Alchemic/ALCModelObjectInjector.h>
#import <Alchemic/ALCMethodArgument.h>
#import <Alchemic/ALCMacros.h>
#import <Alchemic/ALCInternalMacros.h>
#import <Alchemic/ALCException.h>

NS_ASSUME_NONNULL_BEGIN

@implementation NSArray (Alchemic)

-(NSArray<id<ALCDependency>> *) methodArgumentsWithUnknownArgumentHandler:(void (^)(id argument)) unknownArgumentHandler {
    
    NSMutableArray<id<ALCDependency>> *arguments = [[NSMutableArray alloc] initWithCapacity:self.count];
    
    [self enumerateObjectsUsingBlock:^(id nextArgument, NSUInteger idx, BOOL * _Nonnull stop) {
        
        ALCMethodArgument *methodArgument = nil;
        
        if ([nextArgument isKindOfClass:[ALCMethodArgument class]]) {
            methodArgument = (ALCMethodArgument *) nextArgument;
            
        } else if ([nextArgument isKindOfClass:[ALCModelSearchCriteria class]]
                   || [nextArgument conformsToProtocol:@protocol(ALCConstant)]) {
            methodArgument = [ALCMethodArgument argumentWithClass:[NSObject class] criteria:nextArgument, nil];
        }
        
        if (methodArgument) {
            methodArgument.index = (int) idx;
            [arguments addObject:methodArgument];
        } else {
            unknownArgumentHandler(nextArgument);
        }
    }];
    
    return arguments;
}

-(nullable ALCModelSearchCriteria *) modelSearchCriteriaForClass:(Class) aClass {
    
    ALCModelSearchCriteria *searchCriteria;
    for (id criteria in self) {
        
        if ([criteria isKindOfClass:[ALCModelSearchCriteria class]]) {
            
            if (searchCriteria) {
                [searchCriteria appendSearchCriteria:criteria];
            } else {
                searchCriteria = criteria;
            }
            
        } else if ([criteria conformsToProtocol:@protocol(ALCConstant)]) {
            
            if (self.count > 1) {
                throwException(IllegalArgument, @"Only a single constant value is allowed");
            }
            return nil;
            
        } else {
            throwException(IllegalArgument, @"Expected a search criteria or constant. Got: %@", criteria);
        }
        
    }
    
    // Default to the dependency class if no constant or criteria provided.
    return searchCriteria ? searchCriteria: [ALCModelSearchCriteria searchCriteriaForClass:aClass];
}

-(id<ALCInjector>) injectionWithClass:(Class) injectionClass allowConstants:(BOOL) allowConstants {
    
    ALCModelSearchCriteria *searchCriteria = [self modelSearchCriteriaForClass:injectionClass];
    
    if (! allowConstants && !searchCriteria) {
        throwException(IllegalArgument, @"Cannot use constant expressions here.");
    }
    
    return searchCriteria ? [[ALCModelObjectInjector alloc] initWithObjectClass:injectionClass
                                                                       criteria:searchCriteria] : self[0];
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

-(BOOL) dependenciesReadyWithCurrentlyCheckingFlag:(BOOL *) checkingFlag {
    
    // If this flag is set then we have looped back to the original variable. So consider everything to be good.
    if (*checkingFlag) {
        return YES;
    }
    
    // Set the checking flag so that we can detect loops.
    *checkingFlag = YES;
    
    for (id<ALCResolvable> resolvable in self) {
        // If a dependency is not ready then we stop checking and return a failure.
        if (!resolvable.ready) {
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
