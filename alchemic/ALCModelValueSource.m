//
//  ALCDependency.m
//  Alchemic
//
//  Created by Derek Clarkson on 4/02/2016.
//  Copyright © 2016 Derek Clarkson. All rights reserved.
//

@import StoryTeller;

#import <Alchemic/ALCModelValueSource.h>

#import <Alchemic/ALCInternalMacros.h>
#import <Alchemic/ALCModel.h>
#import <Alchemic/ALCObjectFactory.h>
#import <Alchemic/ALCValue.h>
#import <Alchemic/ALCType.h>

NS_ASSUME_NONNULL_BEGIN

@implementation ALCModelValueSource {
    NSArray<id<ALCObjectFactory>> *_resolvedFactories;
}

@synthesize type = _type;

+(instancetype) valueSourceWithCriteria:(ALCModelSearchCriteria *) criteria {
    return [[self alloc] initWithCriteria:criteria];
}

#pragma mark - Lifecycle

-(instancetype) init {
    methodReturningObjectNotImplemented;
}

-(instancetype) initWithCriteria:(ALCModelSearchCriteria *) criteria {
    self = [super init];
    if (self) {
        _type = [ALCType typeWithClass:[NSArray class]];
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

    [self resolveWithModel:model];

    // Resolve dependencies.
    for (id<ALCResolvable> objectFactory in _resolvedFactories) {
        STLog(self, @"Resolving dependency %@", objectFactory);
        [objectFactory resolveWithStack:resolvingStack model:model];
    }
}

-(void) resolveWithModel:(id<ALCModel>) model {
    STLog(self, @"Searching model using %@", _criteria);

    // Find dependencies
    _resolvedFactories = [model objectFactoriesMatchingCriteria:_criteria];
    if ([_resolvedFactories count] == 0) {
        throwException(AlchemicNoDependenciesFoundException, @"No object factories found for criteria: %@", _criteria);
    }

    // Filter for primary factories and replace if there are any present.
    NSArray<id<ALCObjectFactory>> *primaryFactories = [_resolvedFactories filteredArrayUsingPredicate:[NSPredicate predicateWithBlock:^BOOL(id<ALCObjectFactory> objectFactory, NSDictionary<NSString *,id> *bindings) {
        return objectFactory.isPrimary;
    }]];
    if (primaryFactories.count > 0) {
        STLog(self, @"%lu primary factories found.", (unsigned long) primaryFactories.count);
        _resolvedFactories = primaryFactories;
    }

    STLog(self, @"Found %lu object factories", (unsigned long)_resolvedFactories.count);
}

-(BOOL) referencesObjectFactory:(id<ALCObjectFactory>) objectFactory {
    return [_resolvedFactories containsObject:objectFactory];
}

-(BOOL) referencesTransients {
    for (id<ALCObjectFactory> factory in _resolvedFactories) {
        if (factory.isTransient) {
            return YES;
        }
    }
    return NO;
}

-(NSString *)resolvingDescription {
    methodNotImplemented;
    return @"";
}

#pragma mark - Retrieving results.

-(nullable ALCValue *) value {
    NSArray<ALCValue *> *values = [self retrieveValues];
    return [ALCValue withObject:[self objectsFromValues:values]
                     completion:^(__unused NSArray *objects){
        for (ALCValue *value in values) {
            [value complete];
        }
    }];
}

#pragma mark - Internal

-(NSArray<ALCValue *> *) retrieveValues {
    NSMutableArray *results = [[NSMutableArray alloc] init];
    for (id<ALCObjectFactory> factory in _resolvedFactories) {
        [results addObject:factory.value];
    }
    return results;
}

-(NSArray *) objectsFromValues:(NSArray<ALCValue *> *) values {
    NSMutableArray *results = [[NSMutableArray alloc] init];
    for (ALCValue *value in values) {
        id obj = value.object;
        if (obj) {
            [results addObject:obj];
        }
    }
    return results;
}

@end

NS_ASSUME_NONNULL_END

