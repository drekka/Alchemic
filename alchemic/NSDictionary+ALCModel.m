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
#import "ALCInstance.h"
#import "ALCFactoryMethod.h"

#import "ALCNameMatcher.h"
#import "ALCClassMatcher.h"

@implementation NSMutableDictionary (ALCModel)

-(NSSet *) objectsWithMatcherArgs:(id) firstMatcher, ... {
    
    [ALCRuntime validateMatcher:firstMatcher];
    
    // Assemble the matchers.
    va_list args;
    va_start(args, firstMatcher);
    NSMutableSet *finalMatchers = [NSMutableSet setWithObject:firstMatcher];
    id matcher = va_arg(args, id);
    while (matcher != nil) {
        [ALCRuntime validateMatcher:matcher];
        [finalMatchers addObject:matcher];
        matcher = va_arg(args, id);
    }
    va_end(args);
    
    return [self objectsWithMatchers:finalMatchers];
    
}

-(NSSet *) objectsWithMatchers:(NSSet *) matchers {
    NSMutableSet *results = [[NSMutableSet alloc] init];
    for (id<ALCObjectMetadata> objectMetadata in [self metadataWithMatchers:matchers]) {
        [results addObject:objectMetadata.object];
    }
    return results;
}

-(NSSet *) metadataWithMatchers:(NSSet *) matchers {
    ALCResolver *resolver = [[ALCResolver alloc] initWithMatchers:matchers];
    [resolver resolveUsingModel:self];
    return resolver.candidateInstances;
}

#pragma mark - Managing instances

-(id<ALCObjectMetadata>) metadataForObject:(id) object {
    
    // Object will have a matching instance in the model if it has any injection point.
    NSString *className = [NSString stringWithCString:object_getClassName(object) encoding:NSUTF8StringEncoding];
    NSSet *metadataObjects = [self metadataWithMatchers:[NSSet setWithObject:[[ALCNameMatcher alloc] initWithName:className]]];
    if ([metadataObjects count] == 0) {
        // Look for any instances based on the class.
        metadataObjects = [self metadataWithMatchers:[NSSet setWithObject:[[ALCClassMatcher alloc] initWithClass:object_getClass(object)]]];
    }
    
    if ([metadataObjects count] > 1) {
        @throw [NSException exceptionWithName:@"AlchemicTooManyMetadataObjectsForObject"
                                       reason:[NSString stringWithFormat:@"Found too many metadata object matching %s", object_getClassName(object)]
                                     userInfo:nil];
    }
    
    // If nothing found then there are no injections.
    return [metadataObjects count] == 0 ? nil : [metadataObjects anyObject];
    
}

-(id<ALCObjectMetadata>) metadataForClass:(Class) class withName:(NSString *) name {
    NSString *finalName = name;
    if (finalName == nil) {
        finalName = NSStringFromClass(class);
    }
    return self[finalName];
}

#pragma mark - Adding

-(void) addMetadata:(id<ALCObjectMetadata>)objectMetadata name:(NSString *) name {
    logRegistration(@"Storing instance '%@' %s", objectMetadata.name, class_getName(objectMetadata.objectClass));
    if (name != nil) {
        objectMetadata.name = name;
    }
    self[objectMetadata.name] = objectMetadata;
}

-(ALCInstance *) addInstanceForClass:(Class) class inContext:(ALCContext *) context {
    ALCInstance *instance = [[ALCInstance alloc] initWithContext:context objectClass:class];
    [self addMetadata:instance name:nil];
    return instance;
}

-(ALCInstance *) addInstanceForClass:(Class) class inContext:(ALCContext *) context withName:(NSString *) name {
    ALCInstance *instance = [[ALCInstance alloc] initWithContext:context objectClass:class];
    [self addMetadata:instance name:name];
    return instance;
}

-(ALCInstance *) addObject:(id) finalObject inContext:(ALCContext *) context withName:(NSString *) name {
    ALCInstance *instance = [self addInstanceForClass:object_getClass(finalObject) inContext:context withName:name];
    instance.object = finalObject;
    instance.instantiate = YES;
    return instance;
}

-(ALCFactoryMethod *) addFactoryMethod:(SEL) factorySelector
                            toInstance:(ALCInstance *) instance
                            returnType:(Class) returnType {
    ALCFactoryMethod *factoryMethod = [[ALCFactoryMethod alloc] initWithContext:instance.context
                                                                factoryInstance:instance
                                                                factorySelector:factorySelector
                                                                     returnType:returnType];
    [self addMetadata:factoryMethod name:nil];
    return factoryMethod;
}


@end
