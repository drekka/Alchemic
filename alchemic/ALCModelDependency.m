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

-(void) resolveWithStack:(NSMutableArray<NSString *> *)resolvingStack model:(id<ALCModel>) model {

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

-(void) resolveDependencyWithResolvingStack:(NSMutableArray<NSString *> *) resolvingStack
                                   withName:(NSString *) name
                                      model:(id<ALCModel>) model {
    id<ALCDependency> dependency = (id<ALCDependency>) self;
    STLog(_objectClass, @"Resolving %@", name);
    [resolvingStack addObject:name];
    [dependency resolveWithStack:resolvingStack model:model];
    [resolvingStack removeLastObject];
}

-(nullable ALCSimpleBlock) setObject:(id) object variable:(Ivar) variable {
    NSArray<ALCInstantiation *> *instantiations = [self instantiations];
    [ALCRuntime setObject:object variable:variable withValue:[self getValue:instantiations]];
    return [self combineCompletionBlocks:instantiations];
}

-(nullable ALCSimpleBlock) setInvocation:(NSInvocation *) inv argumentIndex:(int) idx {
    NSArray<ALCInstantiation *> *instantiations = [self instantiations];
    id arg = [self getValue:instantiations];
    [inv setArgument:&arg atIndex:idx];
    return [self combineCompletionBlocks:instantiations];
}

#pragma mark - Internal

-(NSArray<ALCInstantiation *> *) instantiations {
    NSMutableArray<ALCInstantiation *> *instantiations = [[NSMutableArray alloc] init];
    for (id<ALCInstantiator> factory in _resolvedFactories) {
        [instantiations addObject:factory.objectInstantiation];
    }
    return instantiations;
}

-(nullable ALCSimpleBlock) combineCompletionBlocks:(NSArray<ALCInstantiation *> *) instantiations {

    NSMutableArray<ALCSimpleBlock> *blocks = [[NSMutableArray alloc] init];
    for (ALCInstantiation *instantiation in instantiations) {
        ALCSimpleBlock completion = instantiation.completion;
        if (completion) {
            [blocks addObject:completion];
        }
    }

    return [blocks combineBlocks];
}

-(id) getValue:(NSArray<ALCInstantiation *> *) instantiations {

    if ([instantiations count] == 1 && ![_objectClass isSubclassOfClass:[NSArray class]]) {
        return instantiations[0].object;
    }

    NSMutableArray *results = [[NSMutableArray alloc] init];
    for (ALCInstantiation *instantiation in instantiations) {
        [results addObject:instantiation.object];
    }
    return results;
}

@end

NS_ASSUME_NONNULL_END

