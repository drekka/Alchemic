//
//  ALCDependency.m
//  Alchemic
//
//  Created by Derek Clarkson on 4/02/2016.
//  Copyright © 2016 Derek Clarkson. All rights reserved.
//

@import StoryTeller;

// :: Framework ::
#import "ALCException.h"
#import "ALCInstantiation.h"
#import "ALCMacros.h"
#import "ALCInternalMacros.h"
#import "ALCModel.h"
#import "ALCModelObjectInjector.h"
#import "ALCObjectFactory.h"
#import "ALCRuntime.h"
#import "NSArray+Alchemic.h"
#import "NSObject+Alchemic.h"
#import "NSInvocation+Alchemic.h"

NS_ASSUME_NONNULL_BEGIN

@implementation ALCModelObjectInjector {
    NSArray<id<ALCObjectFactory>> *_resolvedFactories;
}

@synthesize objectClass = _objectClass;
@synthesize allowNilValues = _allowNilValues;

#pragma mark - Lifecycle

-(instancetype) init {
    methodReturningObjectNotImplemented;
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

    STLog(_objectClass, @"Searching model using %@", _criteria);

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
        STLog(_objectClass, @"%lu primary factories found.", (unsigned long) primaryFactories.count);
        _resolvedFactories = primaryFactories;
    }

    // Resolve dependencies.
    STLog(_objectClass, @"Found %i object factories", _resolvedFactories.count);
    for (id<ALCResolvable> objectFactory in _resolvedFactories) {
        STLog(_objectClass, @"Resolving dependency %@", objectFactory);
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

#pragma mark - Injecting

-(ALCSimpleBlock) setObject:(id) object variable:(Ivar) variable error:(NSError **) error {
    NSArray<ALCInstantiation *> *instantations = [self retrieveInstantiations];
    [object setVariable:variable
                 ofType:_objectClass
              allowNils:self.allowNilValues
                  value:[self valuesFromInstantiations:instantations]
                  error:error];
    return [self completionForInstantiations:instantations];
}

-(BOOL) setInvocation:(NSInvocation *) inv argumentIndex:(int) idx error:(NSError **) error {
    NSArray<ALCInstantiation *> *instantations = [self retrieveInstantiations];
    [self completionForInstantiations:instantations]();
    return [inv setArgIndex:idx
                     ofType:self.objectClass
                  allowNils:self.allowNilValues
                      value:[self valuesFromInstantiations:instantations]
                      error:error];
}

#pragma mark - Retrieving results

-(nullable id) searchResultWithError:(NSError * _Nullable *) error {
    NSArray<ALCInstantiation *> *instantations = [self retrieveInstantiations];
    NSArray *values = [self valuesFromInstantiations:instantations];
    [self completionForInstantiations:instantations]();
    return [ALCRuntime mapValue:values allowNils:NO type:_objectClass error:error];
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

