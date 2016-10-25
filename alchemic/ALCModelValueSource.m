//
//  ALCDependency.m
//  Alchemic
//
//  Created by Derek Clarkson on 4/02/2016.
//  Copyright © 2016 Derek Clarkson. All rights reserved.
//

@import StoryTeller;

#import <Alchemic/ALCModelValueSource.h>

#import <Alchemic/ALCInstantiation.h>
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

    STLog(self, @"Searching model using %@", _criteria);

    // Find dependencies
    _resolvedFactories = [model objectFactoriesMatchingCriteria:_criteria];
    if ([_resolvedFactories count] == 0) {
        throwException(AlchemicNoDependenciesFoundException, @"No object factories found for criteria %@", _criteria);
    }

    // Filter for primary factories and replace if there are any present.
    NSArray<id<ALCObjectFactory>> *primaryFactories = [_resolvedFactories filteredArrayUsingPredicate:[NSPredicate predicateWithBlock:^BOOL(id<ALCObjectFactory> objectFactory, NSDictionary<NSString *,id> *bindings) {
        return objectFactory.isPrimary;
    }]];
    if (primaryFactories.count > 0) {
        STLog(self, @"%lu primary factories found.", (unsigned long) primaryFactories.count);
        _resolvedFactories = primaryFactories;
    }

    // Resolve dependencies.
    STLog(self, @"Found %lu object factories", (unsigned long)_resolvedFactories.count);
    for (id<ALCResolvable> objectFactory in _resolvedFactories) {
        STLog(self, @"Resolving dependency %@", objectFactory);
        [objectFactory resolveWithStack:resolvingStack model:model];
    }
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
    NSArray<ALCInstantiation *> *instantations = [self retrieveInstantiations];
    NSArray *values = [self valuesFromInstantiations:instantations];
    return [ALCValue withValue:values completion:[self completionForInstantiations:instantations]];
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

