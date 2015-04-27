//
//  NSDictionary+ALCModel.m
//  alchemic
//
//  Created by Derek Clarkson on 23/03/2015.
//  Copyright (c) 2015 Derek Clarkson. All rights reserved.
//

#import "NSDictionary+ALCModel.h"

@import Foundation;
@import ObjectiveC;

#import "ALClogger.h"
#import "ALCResolver.h"
#import "ALCRuntime.h"
#import "ALCInternal.h"

#import "ALCNameMatcher.h"
#import "ALCClassMatcher.h"

@implementation NSMutableDictionary (ALCModel)

-(NSArray *) objectsWithMatchers:(id) firstMatcher, ... {
    
    [ALCRuntime validateMatcher:firstMatcher];
    
    // Assemble the matchers.
    va_list args;
    va_start(args, firstMatcher);
    NSMutableArray *finalMatchers = [NSMutableArray arrayWithObject:firstMatcher];
    id matcher = va_arg(args, id);
    while (matcher != nil) {
        [ALCRuntime validateMatcher:matcher];
        [finalMatchers addObject:matcher];
        matcher = va_arg(args, id);
    }
    va_end(args);
    
    return [self objectsWithMatcherArray:finalMatchers];
    
}

-(NSArray *) objectsWithMatcherArray:(NSArray *) matchers {
    NSMutableArray *results = [NSMutableArray array];
    for (ALCInstance *instance in [self instancesWithMatcherArray:matchers]) {
        [results addObject:instance.finalObject];
    }
    return results;
}

-(NSArray *) instancesWithMatcherArray:(NSArray *) matchers {
    ALCResolver *resolver = [[ALCResolver alloc] initWithMatchers:matchers];
    [resolver resolveUsingModel:self];
    return resolver.candidateInstances;
}

#pragma mark - Managing instances

-(ALCInstance *) instanceForObject:(id) object {
    
    // Object will have a matching instance in the model if it has any injection point.
    NSString *className = [NSString stringWithCString:object_getClassName(object) encoding:NSUTF8StringEncoding];
    NSArray *instances = [self instancesWithMatcherArray:@[[[ALCNameMatcher alloc] initWithName:className]]];
    if ([instances count] == 0) {
        // Look for any instances based on the class.
        instances = [self instancesWithMatcherArray:@[[[ALCClassMatcher alloc] initWithClass:object_getClass(object)]]];
    }

    // If nothing found then there are no injections.
    return [instances count] == 0 ? nil : [instances firstObject];
    
}

-(ALCInstance *) instanceForClass:(Class) class withName:(NSString *) name {

    NSString *finalName = name;
    if (finalName == nil) {
        finalName = NSStringFromClass(class);
    }

    ALCInstance *instance = self[finalName];
    if (instance == nil) {
        instance = [self createInstanceForClass:class name:finalName];
    }
    return instance;
}

-(ALCInstance *) createInstanceForClass:(Class) class name:(NSString *) name {
    logRegistration(@"Adding '%2$s' (%1$@) to model", name, class_getName(class));
    ALCInstance *instance = [[ALCInstance alloc] initWithClass:class];
    instance.name = name;
    [self addInstance:instance];
    return instance;
}

#pragma mark - Adding 

-(void) addInstance:(ALCInstance *) instance {
    logRegistration(@"Storing instance '%@' %s", instance.name, class_getName(instance.forClass));
    self[instance.name] = instance;
}

-(void) addObject:(id) finalObject withName:(NSString *) name {
    ALCInstance *instance = [self instanceForClass:object_getClass(finalObject) withName:name];
    instance.finalObject = finalObject;
}


@end
