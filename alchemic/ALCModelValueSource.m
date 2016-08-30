//
//  ALCDependency.m
//  Alchemic
//
//  Created by Derek Clarkson on 4/02/2016.
//  Copyright © 2016 Derek Clarkson. All rights reserved.
//

@import StoryTeller;

#import "ALCException.h"
#import "ALCInstantiation.h"
#import "ALCMacros.h"
#import "ALCInternalMacros.h"
#import "ALCModel.h"
#import "ALCModelValueSource.h"
#import "ALCObjectFactory.h"
#import "ALCRuntime.h"
#import "NSArray+Alchemic.h"
#import "NSObject+Alchemic.h"
#import "NSInvocation+Alchemic.h"
#import "ALCValue.h"

NS_ASSUME_NONNULL_BEGIN

@implementation ALCModelValueSource {
    NSArray<id<ALCObjectFactory>> *_resolvedFactories;
}

@synthesize type = _type;

+(instancetype) valueSourceWithType:(ALCType *) type
                           criteria:(ALCModelSearchCriteria *) criteria {
    return [[self alloc] initWithType:type criteria:criteria];
}

#pragma mark - Lifecycle

-(instancetype) init {
    methodReturningObjectNotImplemented;
}

-(instancetype) initWithType:(ALCType *) type
                    criteria:(ALCModelSearchCriteria *) criteria {
    self = [super init];
    if (self) {
        _type = type;
        _criteria = criteria;
    }
    return self;
}

-(BOOL) isReady {
    for (id<ALCResolvable> objectFactory in _resolvedFactories) {
        if (!objectFactory.isReady) {
            return NO;
        }
    }
    return _resolvedFactories.count > 0;
}

-(void) resolveWithStack:(NSMutableArray<id<ALCResolvable>> *)resolvingStack
                   model:(id<ALCModel>) model {

    STLog(_type, @"Searching model using %@", _criteria);

    // Find dependencies
    _resolvedFactories = [model objectFactoriesMatchingCriteria:_criteria];
    if ([_resolvedFactories count] == 0) {
        throwException(NoDependenciesFound, @"No object factories found for criteria %@", _criteria);
    }

    // Filter for primary factories and replace if there are any present.
    NSArray<id<ALCObjectFactory>> *primaryFactories = [_resolvedFactories filteredArrayUsingPredicate:[NSPredicate predicateWithBlock:^BOOL(id<ALCObjectFactory> objectFactory, NSDictionary<NSString *,id> *bindings) {
        return objectFactory.isPrimary;
    }]];
    if (primaryFactories.count > 0) {
        STLog(_type, @"%lu primary factories found.", (unsigned long) primaryFactories.count);
        _resolvedFactories = primaryFactories;
    }

    // Resolve dependencies.
    STLog(_type, @"Found %i object factories", _resolvedFactories.count);
    for (id<ALCResolvable> objectFactory in _resolvedFactories) {
        STLog(_type, @"Resolving dependency %@", objectFactory);
        [objectFactory resolveWithStack:resolvingStack model:model];
    }
}

-(BOOL) referencesObjectFactory:(id<ALCObjectFactory>) objectFactory {
    return [_resolvedFactories containsObject:objectFactory];
}


-(NSString *)resolvingDescription {
    methodNotImplemented;
    return @"";
}

#pragma mark - Retrieving results.

-(nullable ALCValue *) valueWithError:(NSError * __autoreleasing _Nullable *) error {
    NSArray<ALCInstantiation *> *instantations = [self retrieveInstantiations];
    NSArray *values = [self valuesFromInstantiations:instantations];
    return [ALCValue valueWithType:self.type
                             value:[NSValue valueWithNonretainedObject:values]
                        completion:[self completionForInstantiations:instantations]];
}

#pragma mark - Retrieving results

-(nullable id) searchResultWithError:(NSError * __autoreleasing _Nullable *) error {
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
        id obj = instantiation.object;
        if (obj) {
            [results addObject:obj];
        }
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

