//
//  ALCDependency.m
//  Alchemic
//
//  Created by Derek Clarkson on 4/02/2016.
//  Copyright © 2016 Derek Clarkson. All rights reserved.
//

#import "ALCModelDependency.h"
#import "ALCModel.h"
#import "ALCObjectFactory.h"
#import "ALCInternalMacros.h"

@implementation ALCModelDependency {
    ALCModelSearchCriteria *_criteria;
    NSDictionary<NSString *, id<ALCObjectFactory>> *_resolvedFactories;
}

-(instancetype) initWithCriteria:(ALCModelSearchCriteria *) criteria {
    self = [super init];
    if (self) {
        _criteria = criteria;
    }
    return self;
}

-(bool)ready {
    for (id<ALCObjectFactory> objectFactory in _resolvedFactories.allValues) {
        if (!objectFactory.ready) {
            return NO;
        }
    }
    return YES;
}

-(void) resolveWithStack:(NSMutableArray<ALCDependencyStackItem *> *)resolvingStack model:(id<ALCModel>)model {

    // IF we have already resolved then exit.
    if (_resolvedFactories) {
        return;
    }

    // Find dependencies
    _resolvedFactories = [model objectFactoriesMatchingCriteria:_criteria];
    if ([_resolvedFactories count] == 0) {
        @throw [NSException exceptionWithName:@"AlchemicNoDependenciesFound"
                                       reason:str(@"No object factories found for criteria %@", _criteria)
                                     userInfo:nil];
    }

    // Resolve dependencies.
    for (id<ALCObjectFactory>objectFactory in _resolvedFactories.allValues) {
        [objectFactory resolveWithStack:resolvingStack model:model];
    }
}

-(id) object {
    if ([_resolvedFactories count] > 1) {
        NSMutableArray *results = [[NSMutableArray alloc] init];
        [_resolvedFactories enumerateKeysAndObjectsUsingBlock:^(NSString *name, id<ALCObjectFactory> objectFactory, BOOL *stop) {
            [results addObject:objectFactory.object];
        }];
        return results;
    } else {
        return _resolvedFactories.allValues.firstObject.object;
    }
}

-(Class) objectClass {
    return [_resolvedFactories count] > 1 ? [NSArray class] : _resolvedFactories.allValues.firstObject.objectClass;
}

@end
