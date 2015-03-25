//
//  ALCConstructorInfo.m
//  alchemic
//
//  Created by Derek Clarkson on 23/02/2015.
//  Copyright (c) 2015 Derek Clarkson. All rights reserved.
//

#import "ALCObjectDescription.h"
#import "ALCDependencyResolver.h"
#import "ALCDependencyInjector.h"
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

-(void) resolveDependenciesUsingResolvers:(NSArray *) resolvers {
    for (ALCDependency *dependency in _dependencies) {
        [dependency resolveUsingResolvers:resolvers];
    }
}

-(void) injectDependenciesUsingInjectors:(NSArray *)injectors {
    for (ALCDependency *dependency in _dependencies) {
        [dependency injectObject:_finalObject usingInjectors:injectors];
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
