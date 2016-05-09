//
//  ALCDependency.m
//  Alchemic
//
//  Created by Derek Clarkson on 4/02/2016.
//  Copyright © 2016 Derek Clarkson. All rights reserved.
//

#import <StoryTeller/StoryTeller.h>

#import "ALCModelDependency.h"
#import "ALCModel.h"
#import "ALCObjectFactory.h"
#import "ALCInternalMacros.h"
#import "NSObject+Alchemic.h"
#import "ALCRuntime.h"
#import "ALCInstantiation.h"
#import "NSArray+Alchemic.h"

NS_ASSUME_NONNULL_BEGIN

@implementation ALCModelDependency {
    ALCModelSearchCriteria *_criteria;
    NSArray<id<ALCObjectFactory>> *_resolvedFactories;
}

@synthesize objectClass = _objectClass;

-(instancetype) init {
    [self doesNotRecognizeSelector:@selector(init)];
    return nil;
}

-(instancetype) initWithObjectClass:(Class) objectClass
                           criteria:(ALCModelSearchCriteria *) criteria {
    self = [super init];
    if (self) {
        _objectClass = objectClass;
        _criteria = criteria;
    }
    return self;
}

-(BOOL)ready {
    for (id<ALCResolvable> objectFactory in _resolvedFactories) {
        if (!objectFactory.ready) {
            return NO;
        }
    }
    return YES;
}

-(void) resolveWithStack:(NSMutableArray<NSString *> *)resolvingStack
                   model:(id<ALCModel>) model {

    STLog(_objectClass, @"Searching model using %@", _criteria);

    // Find dependencies
    _resolvedFactories = [model objectFactoriesMatchingCriteria:_criteria].allValues;
    if ([_resolvedFactories count] == 0) {
        throwException(@"AlchemicNoDependenciesFound", @"No object factories found for criteria %@", _criteria);
    }

    // Resolve dependencies.
    STLog(_objectClass, @"Found %i object factories", _resolvedFactories.count);
    for (id<ALCResolvable> objectFactory in _resolvedFactories) {
        STLog(_objectClass, @"Resolving dependency %@", objectFactory);
        [objectFactory resolveWithStack:resolvingStack model:model];
    }
}

-(ALCSimpleBlock) setObject:(id) object variable:(Ivar) variable {
    NSArray<ALCInstantiation *> *instantations = [self retrieveInstantiations];
    [ALCRuntime setObject:object
                 variable:variable
                withValue:[self valuesFromInstantiations:instantations]];
    return [self completionForInstantiations:instantations];
}

-(void) setInvocation:(NSInvocation *) inv argumentIndex:(int) idx {
    NSArray<ALCInstantiation *> *instantations = [self retrieveInstantiations];
    [self completionForInstantiations:instantations]();
    [ALCRuntime setInvocation:inv
                     argIndex:idx
                    withValue:[self valuesFromInstantiations:instantations]
                      ofClass:self.objectClass];
}

-(id) searchResult {
    NSArray<ALCInstantiation *> *instantations = [self retrieveInstantiations];
    NSArray *values = [self valuesFromInstantiations:instantations];
    [self completionForInstantiations:instantations]();
    return values;
}

#pragma mark - Internal

-(NSArray<ALCInstantiation *> *) retrieveInstantiations {
    NSMutableArray *results = [[NSMutableArray alloc] init];
    for (id<ALCObjectFactory> factory in _resolvedFactories) {
        [results addObject:factory.instantiation];
    }
    return results;
}

-(NSArray *) valuesFromInstantiations:(NSArray<ALCInstantiation *> *) instantiations {
    NSMutableArray *results = [[NSMutableArray alloc] init];
    for (ALCInstantiation *instantiation in instantiations) {
        [results addObject:instantiation.object];
    }
    return results;
}

-(ALCSimpleBlock) completionForInstantiations:(NSArray<ALCInstantiation *> *) instantiations {
    return ^{
        for (ALCInstantiation *instantiation in instantiations) {
            [instantiation complete];
        }
    };
}

@end

NS_ASSUME_NONNULL_END

