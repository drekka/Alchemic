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

#import <StoryTeller/StoryTeller.h>
#import "ALCRuntime.h"
#import "ALCClassBuilder.h"
#import "ALCMethodBuilder.h"
#import <Alchemic/ALCNameMatcher.h>
#import <Alchemic/ALCClassMatcher.h>
#import "ALCType.h"

@implementation NSMutableDictionary (ALCModel)

#pragma mark - Finding things

-(NSSet<id> *) objectsWithMatcherArgs:(id) firstMatcher, ... {
    
    [ALCRuntime validateMatcher:firstMatcher];
    
    // Assemble the matchers.
    va_list args;
    va_start(args, firstMatcher);
    
    NSMutableSet<id<ALCMatcher>> *finalMatchers = [[NSMutableSet alloc] init];
    for (id matcher = firstMatcher; matcher != nil; va_arg(args, id)) {
        [ALCRuntime validateMatcher:matcher];
        [finalMatchers addObject:matcher];
    }
    
    va_end(args);
    
    return [self objectsWithMatchers:finalMatchers];
    
}

-(NSSet<id> *) objectsWithMatchers:(NSSet *) matchers {
    NSMutableSet<id> *objects = [[NSMutableSet alloc] init];
    [[self buildersWithMatchers:matchers filterBlock:NULL] enumerateObjectsUsingBlock:^(id<ALCBuilder> builder, BOOL *stop) {
        [objects addObject:builder.value];
    }];
    return objects;
}

-(NSSet<id<ALCBuilder>> *) buildersWithMatchers:(NSSet *)matchers {
    return [self buildersWithMatchers:matchers filterBlock:NULL];
}

#pragma mark - Internal

-(NSSet<ALCClassBuilder *> *) classBuildersWithMatchers:(NSSet *) matchers {
    return [self buildersWithMatchers:matchers
                          filterBlock:^BOOL(id<ALCBuilder> builder) {
                              return [builder isKindOfClass:[ALCClassBuilder class]];
                          }];
}

-(NSSet<id<ALCBuilder>> *) buildersWithMatchers:(NSSet<id<ALCMatcher>> *) matchers filterBlock:(BOOL (^) (id<ALCBuilder> builder)) filterBlock {
    
    NSMutableSet<id<ALCBuilder>> *candidates = [[NSMutableSet alloc] init];
    [self enumerateKeysAndObjectsUsingBlock:^(NSString *name, id<ALCBuilder> builder, BOOL *stop) {
        
        // Run matchers to see if they match. All must accept the candidate object.
        for (id<ALCMatcher> matcher in matchers) {
            if (![matcher matches:builder withName:name]) {
                return;
            }
        }
        
        // Only add to the results if it passes the filter.
        if (filterBlock == NULL || filterBlock(builder)) {
            [candidates addObject:builder];
        }
        
    }];
    
    return candidates;
}

#pragma mark - Enumerating the model

-(void) enumerateClassBuildersWithBlock:(void (^)(NSString *name, ALCClassBuilder *classBuilder, BOOL *stop))block {
    [self enumerateKeysAndObjectsUsingBlock:^(NSString *name, id<ALCBuilder> builder, BOOL *stopEnumerating) {
        if ([builder isKindOfClass:[ALCClassBuilder class]]) {
            block(name, builder, stopEnumerating);
        }
    }];
}

#pragma mark - Managing builders

-(ALCClassBuilder *) findClassBuilderForObject:(id) object {
    
    ALCNameMatcher * nameMatcher = [ALCNameMatcher matcherWithName:NSStringFromClass([object class])];
    NSSet<ALCClassBuilder *> *classBuilders = [self classBuildersWithMatchers:[NSSet setWithObject:nameMatcher]];
    
    if ([classBuilders count] == 0) {
        
        // Now Look for any instances based on the class.
        ALCClassMatcher *classMatcher = [ALCClassMatcher matcherWithClass:object_getClass(object)];
        classBuilders = [self classBuildersWithMatchers:[NSSet setWithObject:classMatcher]];
        if ([classBuilders count] > 0) {
            @throw [NSException exceptionWithName:@"AlchemicUnableToLocateBuilder"
                                           reason:[NSString stringWithFormat:@"Unable to find any builder matching a %s", object_getClassName(object)]
                                         userInfo:nil];
        }
    }
    
    return [classBuilders anyObject];
}

#pragma mark - Adding new builders

-(void) addBuilder:(id<ALCBuilder>)builder underName:(NSString *)name {
    
    NSString *finalName = name == nil ? NSStringFromClass(builder.valueType.typeClass) : name;
    
    if (self[finalName] != nil) {
        @throw [NSException exceptionWithName:@"AlchemicBuilderAlreadyIndexed"
                                       reason:[NSString stringWithFormat:@"Builder already indexed under name: %@", finalName]
                                     userInfo:nil];
    }
    
    log(finalName, @"Registering '%@' %@", finalName, builder);
    self[finalName] = builder;
}

-(ALCClassBuilder *) createClassBuilderForClass:(Class) class inContext:(ALCContext *) context {
    return [self createClassBuilderForClass:class inContext:context withName:nil];
}

-(ALCClassBuilder *) createClassBuilderForClass:(Class) class inContext:(ALCContext *) context withName:(NSString *) name {
    ALCType *type = [[ALCType alloc] initWithClass:class];
    ALCClassBuilder *classBuilder = [[ALCClassBuilder alloc] initWithContext:context valueType:type];
    [self addBuilder:classBuilder underName:name];
    return classBuilder;
}

-(ALCClassBuilder *) addObject:(id) finalObject inContext:(ALCContext *) context withName:(NSString *) name {
    ALCClassBuilder *classBuilder = [self createClassBuilderForClass:object_getClass(finalObject) inContext:context withName:name];
    classBuilder.value = finalObject;
    return classBuilder;
}

-(ALCMethodBuilder *) addMethod:(SEL) factorySelector
                      toBuilder:(ALCClassBuilder *) builder
                     returnType:(ALCType *) returnType
               argumentMatchers:(NSArray<id<ALCMatcher>> *) argumentMatchers {
    
    ALCMethodBuilder *factoryMethod = [[ALCMethodBuilder alloc] initWithContext:builder.context
                                                                      valueType:returnType
                                                            factoryClassBuilder:builder
                                                                factorySelector:factorySelector
                                                               argumentMatchers:argumentMatchers];
    
    [self addBuilder:factoryMethod
           underName:[NSString stringWithFormat:@"%s::%s", class_getName(builder.valueType.typeClass), sel_getName(factorySelector)]];
    return factoryMethod;
    
}

@end
