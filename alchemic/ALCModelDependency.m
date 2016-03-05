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
#import "NSObject+Alchemic.h"
#import "ALCRuntime.h"

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

-(NSArray<id<ALCResolvable>> *)dependencies {
    return _resolvedFactories.allValues;
}

-(BOOL)ready {
    for (id<ALCResolvable> objectFactory in _resolvedFactories.allValues) {
        if (!objectFactory.ready) {
            return NO;
        }
    }
    return YES;
}

-(void) resolveWithStack:(NSMutableArray<NSString *> *)resolvingStack model:(id<ALCModel>)model {

    // Find dependencies
    _resolvedFactories = [model objectFactoriesMatchingCriteria:_criteria];
    if ([_resolvedFactories count] == 0) {
        @throw [NSException exceptionWithName:@"AlchemicNoDependenciesFound"
                                       reason:str(@"No object factories found for criteria %@", _criteria)
                                     userInfo:nil];
    }

    // Resolve dependencies.
    for (id<ALCResolvable> objectFactory in _resolvedFactories.allValues) {
        [objectFactory resolveWithStack:resolvingStack model:model];
    }
}

-(void)setObject:(id) object variable:(Ivar) variable {
    [ALCRuntime setObject:object variable:variable withValue:[self getValue]];
}

-(void) setInvocation:(NSInvocation *) inv argumentIndex:(int) idx {
    id arg = [self getValue];
    [inv setArgument:&arg atIndex:idx];
}

#pragma mark - Internal

-(id) getValue {
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

@end
