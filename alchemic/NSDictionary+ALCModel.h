//
//  NSDictionary+ALCModel.h
//  alchemic
//
//  Created by Derek Clarkson on 23/03/2015.
//  Copyright (c) 2015 Derek Clarkson. All rights reserved.
//

@import Foundation;

#import <Alchemic/ALCBuilder.h>

@class ALCContext;
@class ALCClassBuilder;
@class ALCMethodBuilder;

#import <Alchemic/ALCMatcher.h>

@interface NSDictionary (ALCModel)

#pragma mark - Finding builders

-(ALCClassBuilder *) findClassBuilderForObject:(id) object;

-(NSSet<id<ALCBuilder>> *) buildersWithMatchers:(NSSet *) matchers;

-(void) enumerateClassBuildersWithBlock:(void (^)(NSString *name, ALCClassBuilder *builder, BOOL *stop))block;

#pragma mark - Finding objects

-(NSSet<id> *) objectsWithMatcherArgs:(id) firstMatcher, ...;

-(NSSet<id> *) objectsWithMatchers:(NSSet *) matchers;

#pragma mark - Adding builders

-(void) addBuilder:(id<ALCBuilder>) builder underName:(NSString *) name;

-(ALCClassBuilder *) createClassBuilderForClass:(Class) class inContext:(ALCContext *) context;

-(ALCClassBuilder *) createClassBuilderForClass:(Class) class inContext:(ALCContext *) context withName:(NSString *) name;

-(ALCClassBuilder *) addObject:(id) finalObject inContext:(ALCContext *) context withName:(NSString *) name;

-(ALCMethodBuilder *) addMethod:(SEL) factorySelector
                             toBuilder:(ALCClassBuilder *) builder
                            returnType:(ALCType *) returnType
                      argumentMatchers:(NSArray<id<ALCMatcher>> *) argumentMatchers;

@end
