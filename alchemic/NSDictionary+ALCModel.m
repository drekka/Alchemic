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
#import "ALCDependencyResolver.h"
#import "ALCRuntime.h"
#import "ALCInternal.h"
#import "ALCModelObjectInstance.h"
#import "ALCModelObjectFactoryMethod.h"

#import "ALCNameMatcher.h"
#import "ALCClassMatcher.h"

#import "ALCModelObject.h"

@implementation NSMutableDictionary (ALCModel)

#pragma mark - Finding things

-(NSSet *) objectsWithMatcherArgs:(id) firstMatcher, ... {
    
    [ALCRuntime validateMatcher:firstMatcher];
    
    // Assemble the matchers.
    va_list args;
    va_start(args, firstMatcher);
    
    NSMutableSet *finalMatchers = [[NSMutableSet alloc] init];
    for (id matcher = firstMatcher; matcher != nil; va_arg(args, id)) {
        [ALCRuntime validateMatcher:matcher];
        [finalMatchers addObject:matcher];
    }
    
    va_end(args);
    
    return [self objectsWithMatchers:finalMatchers];
    
}

-(NSSet *) objectsWithMatchers:(NSSet *) matchers {
    return [self findWithMatchers:matchers
                    selectorBlock:^id(id<ALCModelObject> metadata) {
                        return metadata.object;
                    }];
}

-(NSSet *) instancesWithMatcher:(id<ALCMatcher>) matcher {
    return [self instancesWithMatchers:[NSSet setWithObject:matcher]];
}

-(NSSet *) instancesWithMatchers:(NSSet *) matchers {
    return [self findWithMatchers:matchers
                    selectorBlock:^id(id<ALCModelObject> metadata) {
                        return [metadata isKindOfClass:[ALCModelObjectInstance class]] ? metadata : nil;
                    }];
}

-(NSSet *) metadataWithMatchers:(NSSet *) matchers {
    ALCDependencyResolver *resolver = [[ALCDependencyResolver alloc] initWithMatchers:matchers];
    [resolver resolveUsingModel:self];
    return resolver.candidateInstances;
}

-(NSSet *) metadataWithMatcher:(id<ALCMatcher>) matcher {
    return [self metadataWithMatchers:[NSSet setWithObject:matcher]];
}

-(NSSet *) findWithMatchers:(NSSet *) matchers selectorBlock:(id (^) (id<ALCModelObject> metadata)) selectorBlock {
    NSMutableSet *results = [[NSMutableSet alloc] init];
    for (id<ALCModelObject> objectMetadata in [self metadataWithMatchers:matchers]) {
        id result = selectorBlock(objectMetadata);
        if (result != nil) {
            [results addObject:result];
        }
    }
    return results;
}

-(void) enumerateInstancesUsingBlock:(void (^)(NSString *name, ALCModelObjectInstance *instance, BOOL *stop))block {
    Class instanceClass = [ALCModelObjectInstance class];
        [self enumerateKeysAndObjectsUsingBlock:^(NSString *name, id<ALCModelObject> modelObject, BOOL *stopEnumerating) {
            if ([modelObject isKindOfClass:instanceClass]) {
                block(name, modelObject, stopEnumerating);
            }
        }];
}

#pragma mark - Managing instances

-(ALCModelObjectInstance *) instanceForObject:(id) object {
    
    // Look for instance data based on the class name first.
    Class objectClass = object_getClass(object);
    NSSet *instances = [self instancesWithMatcher:[[ALCNameMatcher alloc] initWithName:NSStringFromClass(objectClass)]];
    if ([instances count] == 0) {
        // Now Look for any instances based on the class.
        instances = [self instancesWithMatcher:[[ALCClassMatcher alloc] initWithClass:objectClass]];
        if ([instances count] > 0) {
            @throw [NSException exceptionWithName:@"AlchemicUnableToLocateMetadata"
                                           reason:[NSString stringWithFormat:@"Unable to find any metata for a instance of %s", object_getClassName(object)]
                                         userInfo:nil];
        }
    }
    return [instances anyObject];
}

#pragma mark - Adding new meta data

-(void) indexMetadata:(id<ALCModelObject>) objectMetadata underName:(NSString *) name {
    
    NSString *finalName = name == nil ? NSStringFromClass(objectMetadata.objectClass) : name;
    
    if (self[finalName] != nil) {
        @throw [NSException exceptionWithName:@"AlchemicMetadataAlreadyIndexed"
                                       reason:[NSString stringWithFormat:@"Metadata already indexed under name: %@", finalName]
                                     userInfo:nil];
    }
    
    logRegistration(@"Registering '%@' %@", finalName, objectMetadata);
    self[finalName] = objectMetadata;
}

-(ALCModelObjectInstance *) addInstanceForClass:(Class) class inContext:(ALCContext *) context {
    ALCModelObjectInstance *instance = [[ALCModelObjectInstance alloc] initWithContext:context objectClass:class];
    [self indexMetadata:instance underName:nil];
    return instance;
}

-(ALCModelObjectInstance *) addInstanceForClass:(Class) class inContext:(ALCContext *) context withName:(NSString *) name {
    ALCModelObjectInstance *instance = [[ALCModelObjectInstance alloc] initWithContext:context objectClass:class];
    [self indexMetadata:instance underName:name];
    return instance;
}

-(ALCModelObjectInstance *) addObject:(id) finalObject inContext:(ALCContext *) context withName:(NSString *) name {
    ALCModelObjectInstance *instance = [self addInstanceForClass:object_getClass(finalObject) inContext:context withName:name];
    instance.object = finalObject;
    instance.instantiate = YES;
    return instance;
}

-(ALCModelObjectFactoryMethod *) addFactoryMethod:(SEL) factorySelector
                            toInstance:(ALCModelObjectInstance *) instance
                            returnType:(Class) returnType
                      argumentMatchers:(NSArray *) argumentMatchers {
    ALCModelObjectFactoryMethod *factoryMethod = [[ALCModelObjectFactoryMethod alloc] initWithContext:instance.context
                                                                factoryInstance:instance
                                                                factorySelector:factorySelector
                                                                     returnType:returnType
                                                               argumentMatchers:argumentMatchers];
    [self indexMetadata:factoryMethod underName:[NSString stringWithFormat:@"%s::%s", class_getName(instance.objectClass), sel_getName(factorySelector)]];
    return factoryMethod;
}

@end
