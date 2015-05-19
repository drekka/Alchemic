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
#import "ALCDependency.h"
#import "ALCRuntime.h"
#import "ALCInternal.h"
#import "ALCResolvableObject.h"
#import "ALCResolvableMethod.h"

#import "ALCNameMatcher.h"
#import "ALCClassMatcher.h"

#import "ALCResolvable.h"

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
    return [self filterResolvablesWithMatchers:matchers
                                 selectorBlock:^id(id<ALCResolvable> metadata) {
                                     return metadata.object;
                                 }];
}

-(NSSet *) resolvablesWithMatchers:(NSSet *) matchers {
    ALCDependency *resolver = [[ALCDependency alloc] initWithMatchers:matchers];
    [resolver resolveUsingModel:self];
    return resolver.candidates;
}

-(NSSet *) resolvablesWithMatcher:(id<ALCMatcher>) matcher {
    return [self resolvablesWithMatchers:[NSSet setWithObject:matcher]];
}

-(void) enumerateResolvableObjectsUsingBlock:(void (^)(NSString *name, ALCResolvableObject *instance, BOOL *stop))block {
    Class resolvableObjectClass = [ALCResolvableObject class];
    [self enumerateKeysAndObjectsUsingBlock:^(NSString *name, id<ALCResolvable> resolvable, BOOL *stopEnumerating) {
        if ([resolvable isKindOfClass:resolvableObjectClass]) {
            block(name, resolvable, stopEnumerating);
        }
    }];
}

#pragma mark - Internal

-(NSSet *) resolvableObjectsWithMatcher:(id<ALCMatcher>) matcher {
    return [self filterResolvablesWithMatchers:[NSSet setWithObject:matcher]
                                 selectorBlock:^id(id<ALCResolvable> metadata) {
                                     return [metadata isKindOfClass:[ALCResolvableObject class]] ? metadata : nil;
                                 }];
}

-(NSSet *) filterResolvablesWithMatchers:(NSSet *) matchers selectorBlock:(id (^) (id<ALCResolvable> metadata)) selectorBlock {
    NSMutableSet *results = [[NSMutableSet alloc] init];
    for (id<ALCResolvable> objectMetadata in [self resolvablesWithMatchers:matchers]) {
        id result = selectorBlock(objectMetadata);
        if (result != nil) {
            [results addObject:result];
        }
    }
    return results;
}

#pragma mark - Managing resolvable objects

-(ALCResolvableObject *) findResolvableObjectForObject:(id) object {
    
    Class objectClass = object_getClass(object);
    NSSet *resolvableObjects = [self resolvableObjectsWithMatcher:[[ALCNameMatcher alloc] initWithName:NSStringFromClass(objectClass)]];
    
    if ([resolvableObjects count] == 0) {
        
        // Now Look for any instances based on the class.
        resolvableObjects = [self resolvableObjectsWithMatcher:[[ALCClassMatcher alloc] initWithClass:objectClass]];
        if ([resolvableObjects count] > 0) {
            @throw [NSException exceptionWithName:@"AlchemicUnableToLocateMetadata"
                                           reason:[NSString stringWithFormat:@"Unable to find any metata for a instance of %s", object_getClassName(object)]
                                         userInfo:nil];
        }
    }
    
    return [resolvableObjects anyObject];
}

#pragma mark - Adding new meta data

-(void) storeResolvable:(id<ALCResolvable>) objectMetadata underName:(NSString *) name {
    
    NSString *finalName = name == nil ? NSStringFromClass(objectMetadata.objectClass) : name;
    
    if (self[finalName] != nil) {
        @throw [NSException exceptionWithName:@"AlchemicMetadataAlreadyIndexed"
                                       reason:[NSString stringWithFormat:@"Metadata already indexed under name: %@", finalName]
                                     userInfo:nil];
    }
    
    logRegistration(@"Registering '%@' %@", finalName, objectMetadata);
    self[finalName] = objectMetadata;
}

-(ALCResolvableObject *) addResolvableObjectForClass:(Class) class inContext:(ALCContext *) context {
    ALCResolvableObject *resolvableObject = [[ALCResolvableObject alloc] initWithContext:context objectClass:class];
    [self storeResolvable:resolvableObject underName:nil];
    return resolvableObject;
}

-(ALCResolvableObject *) addResolvableObjectForClass:(Class) class inContext:(ALCContext *) context withName:(NSString *) name {
    ALCResolvableObject *resolvableObject = [[ALCResolvableObject alloc] initWithContext:context objectClass:class];
    [self storeResolvable:resolvableObject underName:name];
    return resolvableObject;
}

-(ALCResolvableObject *) addObject:(id) finalObject inContext:(ALCContext *) context withName:(NSString *) name {
    ALCResolvableObject *resolvableObject = [self addResolvableObjectForClass:object_getClass(finalObject) inContext:context withName:name];
    resolvableObject.object = finalObject;
    resolvableObject.instantiate = YES;
    return resolvableObject;
}

-(ALCResolvableMethod *) addMethod:(SEL) factorySelector
                toResolvableObject:(ALCResolvableObject *) resolvableObject
                        returnType:(Class) returnType
                  argumentMatchers:(NSArray *) argumentMatchers {
    ALCResolvableMethod *factoryMethod = [[ALCResolvableMethod alloc] initWithContext:resolvableObject.context
                                                                      factoryInstance:resolvableObject
                                                                      factorySelector:factorySelector
                                                                           returnType:returnType
                                                                     argumentMatchers:argumentMatchers];
    [self storeResolvable:factoryMethod underName:[NSString stringWithFormat:@"%s::%s", class_getName(resolvableObject.objectClass), sel_getName(factorySelector)]];
    return factoryMethod;
}

@end
