//
//  NSDictionary+ALCModel.h
//  alchemic
//
//  Created by Derek Clarkson on 23/03/2015.
//  Copyright (c) 2015 Derek Clarkson. All rights reserved.
//

@import Foundation;

#import "ALCBuilder.h"
@class ALCContext;
@class ALCClassBuilder;
@class ALCFactoryMethodBuilder;


#import "ALCMatcher.h"

@interface NSDictionary (ALCModel)

#pragma mark - Finding builders

-(ALCClassBuilder *) findBuilderForObject:(id) object;

-(NSSet *) buildersWithMatchers:(NSSet *) matchers;

-(void) enumerateClassBuildersWithBlock:(void (^)(NSString *name, ALCClassBuilder *builder, BOOL *stop))block;

#pragma mark - Finding objects

-(NSSet *) objectsWithMatcherArgs:(id) firstMatcher, ...;

-(NSSet *) objectsWithMatchers:(NSSet *) matchers;

#pragma mark - Adding builders

-(void) addBuilder:(id<ALCBuilder>) builder underName:(NSString *) name;

-(ALCClassBuilder *) createClassBuilderForClass:(Class) class inContext:(ALCContext *) context;

-(ALCClassBuilder *) createClassBuilderForClass:(Class) class inContext:(ALCContext *) context withName:(NSString *) name;

-(ALCClassBuilder *) addObject:(id) finalObject inContext:(ALCContext *) context withName:(NSString *) name;

-(ALCFactoryMethodBuilder *) addMethod:(SEL) factorySelector
                             toBuilder:(ALCClassBuilder *) builder
                            returnType:(Class) returnType
                      argumentMatchers:(NSArray *) argumentMatchers;

@end
