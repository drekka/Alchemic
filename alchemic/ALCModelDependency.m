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

@implementation ALCModelDependency {
    ALCModelSearchCriteria *_criteria;
    NSArray<id<ALCObjectFactory>> *_resolvedFactories;
}

-(instancetype) initWithCriteria:(ALCModelSearchCriteria *) criteria {
    self = [super init];
    if (self) {
        _criteria = criteria;
    }
    return self;
}

-(bool)resolved {
    if (!_resolvedFactories) {
        return NO;
    }
    for (id<ALCObjectFactory>objectFactory in _resolvedFactories) {
        if (!objectFactory.resolved) {
            return NO;
        }
    }
    return YES;
}

-(void) resolveWithStack:(NSMutableArray<id<ALCResolvable>> *)resolvingStack model:(id<ALCModel>)model {

    // Find dependencies
    _resolvedFactories = [model objectFactoriesMatchingCriteria:_criteria];
    if ([_resolvedFactories count] == 0) {
        @throw [NSException exceptionWithName:@"AlchemicNoDependenciesFound"
                                       reason:[NSString stringWithFormat:@"No object factories found for criteria %@", _criteria]
                                     userInfo:nil];
    }

    // Resolve dependencies.
    for (id<ALCObjectFactory>objectFactory in _resolvedFactories) {
        [objectFactory resolveWithStack:resolvingStack model:model];
    }
}

-(id) object {
    if ([_resolvedFactories count] > 1) {
        NSMutableArray *results = [[NSMutableArray alloc] init];
        [_resolvedFactories enumerateObjectsUsingBlock:^(id<ALCObjectFactory> objectFactory, NSUInteger idx, BOOL *stop) {
            [results addObject:objectFactory.object];
        }];
        return results;
    } else {
        return [_resolvedFactories firstObject].object;
    }
}

-(Class) objectClass {
    return [_resolvedFactories count] > 1 ? [NSArray class] : [_resolvedFactories firstObject].objectClass;
}

@end
