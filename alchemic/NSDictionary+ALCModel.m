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

#import "ALCObjectMetadata.h"

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
                    selectorBlock:^id(id<ALCObjectMetadata> metadata) {
                        return metadata.object;
                    }];
}

-(NSSet *) instancesWithMatcher:(id<ALCMatcher>) matcher {
    return [self instancesWithMatchers:[NSSet setWithObject:matcher]];
}

-(NSSet *) instancesWithMatchers:(NSSet *) matchers {
    return [self findWithMatchers:matchers
                    selectorBlock:^id(id<ALCObjectMetadata> metadata) {
                        return [metadata isKindOfClass:[ALCInstance class]] ? metadata : nil;
                    }];
}

-(NSSet *) metadataWithMatchers:(NSSet *) matchers {
    ALCResolver *resolver = [[ALCResolver alloc] initWithMatchers:matchers];
    [resolver resolveUsingModel:self];
    return resolver.candidateInstances;
}

-(NSSet *) metadataWithMatcher:(id<ALCMatcher>) matcher {
    return [self metadataWithMatchers:[NSSet setWithObject:matcher]];
}

-(NSSet *) findWithMatchers:(NSSet *) matchers selectorBlock:(id (^) (id<ALCObjectMetadata> metadata)) selectorBlock {
    NSMutableSet *results = [[NSMutableSet alloc] init];
    for (id<ALCObjectMetadata> objectMetadata in [self metadataWithMatchers:matchers]) {
        id result = selectorBlock(objectMetadata);
        if (result != nil) {
            [results addObject:result];
        }
    }
    return results;
}

#pragma mark - Managing instances

-(ALCInstance *) instanceForObject:(id) object {
    
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

-(void) indexMetadata:(id<ALCObjectMetadata>) objectMetadata underName:(NSString *) name {
    
    NSString *finalName = name == nil ? NSStringFromClass(objectMetadata.objectClass) : name;
    
    if (self[finalName] != nil) {
        @throw [NSException exceptionWithName:@"AlchemicMetadataAlreadyIndexed"
                                       reason:[NSString stringWithFormat:@"Metadata already indexed under name: %@", finalName]
                                     userInfo:nil];
    }
    
    logRegistration(@"Registering '%@' %@", finalName, objectMetadata);
    self[finalName] = objectMetadata;
}

-(ALCInstance *) addInstanceForClass:(Class) class inContext:(ALCContext *) context {
    ALCInstance *instance = [[ALCInstance alloc] initWithContext:context objectClass:class];
    [self indexMetadata:instance underName:nil];
    return instance;
}

-(ALCInstance *) addInstanceForClass:(Class) class inContext:(ALCContext *) context withName:(NSString *) name {
    ALCInstance *instance = [[ALCInstance alloc] initWithContext:context objectClass:class];
    [self indexMetadata:instance underName:name];
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
                            returnType:(Class) returnType
                      argumentMatchers:(NSArray *) argumentMatchers {
    ALCFactoryMethod *factoryMethod = [[ALCFactoryMethod alloc] initWithContext:instance.context
                                                                factoryInstance:instance
                                                                factorySelector:factorySelector
                                                                     returnType:returnType
                                                               argumentMatchers:argumentMatchers];
    [self indexMetadata:factoryMethod underName:[NSString stringWithFormat:@"%s::%s", class_getName(instance.objectClass), sel_getName(factorySelector)]];
    return factoryMethod;
}

@end
