//
//  ALCConstructorInfo.m
//  alchemic
//
//  Created by Derek Clarkson on 23/02/2015.
//  Copyright (c) 2015 Derek Clarkson. All rights reserved.
//

#import "ALCObjectDescription.h"
#import "ALCDependencyResolver.h"
#import "ALCDependency.h"
#import "ALCLogger.h"
#import "ALCObjectFactory.h"

@class ALCDependency;

@implementation ALCObjectDescription {
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

-(void) addDependency:(ALCDependency *)dependency {
    [(NSMutableArray *)_dependencies addObject:dependency];
}

-(void) resolveDependenciesUsingResolvers:(NSArray *) dependencyResolvers {
    for (ALCDependency *dependency in _dependencies) {
        
        NSDictionary *candidates;
        for (id<ALCDependencyResolver> resolver in [dependencyResolvers reverseObjectEnumerator]) {
            logDependencyResolving(@"Asking %s to resolve %s::%s", class_getName([resolver class]), class_getName(dependency.parentClass), ivar_getName(dependency.variable));
            candidates = [resolver resolveDependency:dependency];
            if (candidates != nil) {
                break;
            }
        }

        dependency.candidateObjectDescriptions = candidates;
        if (dependency.candidateObjectDescriptions == nil) {
            @throw [NSException exceptionWithName:@"AlchemicDependencyNotFound"
                                           reason:[NSString stringWithFormat:@"Unable to resolve dependency for: %s::%s", class_getName(dependency.parentClass), ivar_getName(dependency.variable)]
                                         userInfo:nil];
        }
        logDependencyResolving(@"Resolved dependency");
    }
}

-(void) instantiateUsingFactories:(NSArray *) objectFactories {

    for (id<ALCObjectFactory> objectFactory in objectFactories) {
        _finalObject = [objectFactory createObjectFromObjectDescription:self];
        if (_finalObject) {
            return;
        }
    }

    @throw [NSException exceptionWithName:@"AlchemicUnableToCreateInstance"
                                   reason:[NSString stringWithFormat:@"Unable to create an instance of %s", class_getName(self.forClass)]
                                 userInfo:nil];
}

@end
