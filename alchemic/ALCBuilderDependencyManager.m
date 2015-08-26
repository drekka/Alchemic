//
//  ALCBuilderDependencyManager.m
//  alchemic
//
//  Created by Derek Clarkson on 24/08/2015.
//  Copyright © 2015 Derek Clarkson. All rights reserved.
//
#import <StoryTeller/StoryTeller.h>

#import "ALCBuilderDependencyManager.h"
#import "NSObject+ALCResolvable.h"
#import "ALCDependency.h"
#import "ALCInternalMacros.h"

NS_ASSUME_NONNULL_BEGIN

@interface ALCBuilderDependencyManager ()
@property (nonatomic, assign) BOOL available;
@end

@implementation ALCBuilderDependencyManager {
    NSMutableArray<ALCDependency *> *_dependencies;
}

@synthesize available = _available;

#pragma mark - LIfecycle

-(void) dealloc {
    [self kvoRemoveWatchAvailableFromResolvableArray:_dependencies];
}

-(instancetype) init {
    self = [super init];
    if (self) {
        _dependencies = [[NSMutableArray alloc] init];
        _available = YES;
    }
    return self;
}

#pragma mark - Tasks

-(NSUInteger)numberOfDependencies {
    return [_dependencies count];
}

-(void) addDependency:(ALCDependency *) dependency {
    [self kvoWatchAvailable:dependency];
    [_dependencies addObject:dependency];
    _available = NO;

}

-(NSArray *)dependencyValues {
    NSMutableArray *values = [NSMutableArray arrayWithCapacity:[self numberOfDependencies]];
    [self enumerateDependencies:^(ALCDependency * _Nonnull dependency, NSUInteger idx, BOOL * _Nonnull stop) {
        [values addObject:dependency.value];
    }];
    return values;
}

-(void) enumerateDependencies:(void (^)(ALCDependency *dependency, NSUInteger idx, BOOL *stop)) block {

    if (!self.available) {
        @throw [NSException exceptionWithName:@"AlchemicDependenciesNotAvailable"
                                       reason:@"Cannot enumerate dependencies when they are not available."
                                     userInfo:nil];
    }

    [_dependencies enumerateObjectsUsingBlock:block];
}

-(void)resolveWithPostProcessors:(NSSet<id<ALCDependencyPostProcessor>> *)postProcessors
                 dependencyStack:(NSMutableArray<id<ALCResolvable>> *)dependencyStack {
    for(ALCDependency *dependency in _dependencies) {
        STLog(ALCHEMIC_LOG, @"Resolving dependency %@", dependency);
        [dependency resolveWithPostProcessors:postProcessors dependencyStack:dependencyStack];
    };
    _available = [self dependenciesAvailable];
}

#pragma mark - KVO

-(void)observeValueForKeyPath:(nullable NSString *)keyPath
                     ofObject:(nullable id)object
                       change:(nullable NSDictionary<NSString *,id> *)change
                      context:(nullable void *)context {
    if (!self.available && [self dependenciesAvailable]) {
        STLog(ALCHEMIC_LOG, @"Dependencies are available, triggering KVO");
        self.available = YES; // Trigger KVO.
    }
}

#pragma mark - Internal

-(BOOL) dependenciesAvailable {
    for (ALCDependency *dependency in _dependencies) {
        if (!dependency.available) {
            return NO;
        }
    }
    return YES;
}

@end

NS_ASSUME_NONNULL_END
