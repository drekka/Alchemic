//
//  ALCConstructorInfo.m
//  alchemic
//
//  Created by Derek Clarkson on 23/02/2015.
//  Copyright (c) 2015 Derek Clarkson. All rights reserved.
//

#import "ALCClassInfo.h"
#import "ALCDependencyResolver.h"
#import "ALCDependencyInfo.h"
#import "ALCLogger.h"

@class ALCDependencyInfo;

@implementation ALCClassInfo {
    NSMutableArray *_dependencies;
}

-(instancetype) initWithClass:(Class) forClass name:(NSString *) name{
    self = [super init];
    if (self) {
        _forClass = forClass;
        _name = name;
        _dependencies = [[NSMutableArray alloc] init];
    }
    return self;
}

-(void) addDependency:(ALCDependencyInfo *)dependency {
    [(NSMutableArray *)_dependencies addObject:dependency];
}

-(void) resolveDependenciesUsingResolvers:(NSArray *) dependencyResolvers {
    for (ALCDependencyInfo *dependencyInfo in _dependencies) {
        
        NSDictionary *candidates;
        for (id<ALCDependencyResolver> resolver in [dependencyResolvers reverseObjectEnumerator]) {
            logDependencyResolving(@"Asking %s to resolve %s::%s", class_getName([resolver class]), class_getName(dependencyInfo.parentClass), ivar_getName(dependencyInfo.variable));
            candidates = [resolver resolveDependency:dependencyInfo];
            if (candidates != nil) {
                break;
            }
        }

        dependencyInfo.targetClassInfoObjects = candidates;
        if (dependencyInfo.targetClassInfoObjects == nil) {
            @throw [NSException exceptionWithName:@"AlchemicDependencyNotFound"
                                           reason:[NSString stringWithFormat:@"Unable to resolve dependency for: %s::%s", class_getName(dependencyInfo.parentClass), ivar_getName(dependencyInfo.variable)]
                                         userInfo:nil];
        }
        logDependencyResolving(@"Resolved dependency");
    }
}

@end
