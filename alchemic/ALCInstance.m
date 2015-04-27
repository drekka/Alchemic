//
//  ALCConstructorInfo.m
//  alchemic
//
//  Created by Derek Clarkson on 23/02/2015.
//  Copyright (c) 2015 Derek Clarkson. All rights reserved.
//

#import "ALCInstance.h"
@import ObjectiveC;

#import "ALCDependency.h"
#import "ALCRuntime.h"
#import "ALCObjectFactory.h"
#import "ALCLogger.h"

@implementation ALCInstance {
    NSMutableArray *_dependencies;
    NSArray *_initialisationStrategies;
}

-(instancetype) initWithClass:(Class) class {
    self = [super init];
    if (self) {
        _initialisationStrategies = @[];
        _forClass = class;
        _dependencies = [[NSMutableArray alloc] init];
        self.name = NSStringFromClass(class);
    }
    return self;
}

-(NSString *) debugDescription {
    return [NSString stringWithFormat:@"Instance of %s", class_getName(_forClass)];
}

-(void) addDependency:(NSString *) inj, ... {
    
    va_list args;
    va_start(args, inj);
    NSMutableArray *finalMatchers;
    id matcher = va_arg(args, id);
    while (matcher != nil) {
        
        if (![matcher conformsToProtocol:@protocol(ALCMatcher)]) {
            @throw [NSException exceptionWithName:@"AlchemicUnableNotAMatcher"
                                           reason:[NSString stringWithFormat:@"Passed matcher %s does not conform to the ALCMatcher protocol", object_getClassName(matcher)]
                                         userInfo:nil];
        }
        
        if (finalMatchers == nil) {
            finalMatchers = [[NSMutableArray alloc] init];
        }
        [finalMatchers addObject:matcher];
        matcher = va_arg(args, id);
    }
    va_end(args);
    
    [self addDependency:inj withMatchers:finalMatchers];
}

-(void) addDependency:(NSString *) inj withMatchers:(NSArray *) matchers {
    // Create the dependency info to be store.
    Ivar variable = [ALCRuntime class:_forClass variableForInjectionPoint:inj];
    [_dependencies addObject:[[ALCDependency alloc] initWithVariable:variable matchers:matchers]];
}

-(void) resolveDependenciesWithModel:(NSDictionary *) model {
    for (ALCDependency *dependency in _dependencies) {
        [dependency resolveUsingModel:model];
    }
    
}

-(void) injectDependenciesUsingInjectors:(NSArray *) dependencyInjectors {
    if (self.finalObject == nil) {
        return;
    }
    for (ALCDependency *dependency in _dependencies) {
        [dependency injectObject:self.finalObject usingInjectors:dependencyInjectors];
    }
}

-(void) instantiateUsingFactories:(NSArray *) objectFactories {
    if (self.instantiate && self.finalObject == nil) { // Allow for pre-built objects.
        
        logCreation(@"Instantiating '%@' (%s)", self.name, class_getName(self.forClass));
        for (id<ALCObjectFactory> objectFactory in objectFactories) {
            self.finalObject = [objectFactory createObjectFromInstance:self];
            if (self.finalObject != nil) {
                break;
            }
        }
        
        if (self.finalObject == nil) {
            @throw [NSException exceptionWithName:@"AlchemicUnableToCreateInstance"
                                           reason:[NSString stringWithFormat:@"Unable to create an instance of %s", class_getName(self.forClass)]
                                         userInfo:nil];
        }
    }
}

-(void) addInitialisationStrategy:(id<ALCInitialisationStrategy>) initialisationStrategy {
    _initialisationStrategies = [_initialisationStrategies arrayByAddingObject:initialisationStrategy];
}

@end
