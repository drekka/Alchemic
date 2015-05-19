//
//  NSDictionary+ALCModel.h
//  alchemic
//
//  Created by Derek Clarkson on 23/03/2015.
//  Copyright (c) 2015 Derek Clarkson. All rights reserved.
//

@import Foundation;

#import "ALCResolvable.h"

@class ALCContext;
@class ALCResolvableObject;
@class ALCResolvableMethod;

#import "ALCMatcher.h"

@interface NSDictionary (ALCModel)

#pragma mark - Finding Metadata

-(ALCResolvableObject *) findResolvableObjectForObject:(id) object;

-(NSSet *) resolvablesWithMatchers:(NSSet *) matchers;

-(NSSet *) resolvablesWithMatcher:(id<ALCMatcher>) matcher;

-(void) enumerateResolvableObjectsUsingBlock:(void (^)(NSString *name, ALCResolvableObject *resolvableObject, BOOL *stop))block;

#pragma mark - Finding objects

-(NSSet *) objectsWithMatcherArgs:(id) firstMatcher, ...;

-(NSSet *) objectsWithMatchers:(NSSet *) matchers;

#pragma mark - Adding new Metadata

-(void) storeResolvable:(id<ALCResolvable>) objectMetadata underName:(NSString *) name;

-(ALCResolvableObject *) addResolvableObjectForClass:(Class) class inContext:(ALCContext *) context;

-(ALCResolvableObject *) addResolvableObjectForClass:(Class) class inContext:(ALCContext *) context withName:(NSString *) name;

-(ALCResolvableObject *) addObject:(id) finalObject inContext:(ALCContext *) context withName:(NSString *) name;

-(ALCResolvableMethod *) addMethod:(SEL) factorySelector
                toResolvableObject:(ALCResolvableObject *) resolvableObject
                        returnType:(Class) returnType
                  argumentMatchers:(NSArray *) argumentMatchers;

@end
