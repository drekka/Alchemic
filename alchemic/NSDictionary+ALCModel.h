//
//  NSDictionary+ALCModel.h
//  alchemic
//
//  Created by Derek Clarkson on 23/03/2015.
//  Copyright (c) 2015 Derek Clarkson. All rights reserved.
//

@import Foundation;

#import "ALCModelObject.h"

@class ALCContext;
@class ALCModelObjectInstance;
@class ALCModelObjectFactoryMethod;

#import "ALCMatcher.h"

@interface NSDictionary (ALCModel)

#pragma mark - Finding Metadata

-(ALCModelObjectInstance *) instanceForObject:(id) object;

-(NSSet *) metadataWithMatchers:(NSSet *) matchers;

-(NSSet *) metadataWithMatcher:(id<ALCMatcher>) matcher;

-(void) enumerateInstancesUsingBlock:(void (^)(NSString *name, ALCModelObjectInstance *instance, BOOL *stop))block;

#pragma mark - Finding objects

-(NSSet *) objectsWithMatcherArgs:(id) firstMatcher, ...;

-(NSSet *) objectsWithMatchers:(NSSet *) matchers;

#pragma mark - Adding new Metadata

-(void) indexMetadata:(id<ALCModelObject>) objectMetadata underName:(NSString *) name;

-(ALCModelObjectInstance *) addInstanceForClass:(Class) class inContext:(ALCContext *) context;

-(ALCModelObjectInstance *) addInstanceForClass:(Class) class inContext:(ALCContext *) context withName:(NSString *) name;

-(ALCModelObjectInstance *) addObject:(id) finalObject inContext:(ALCContext *) context withName:(NSString *) name;

-(ALCModelObjectFactoryMethod *) addFactoryMethod:(SEL) factorySelector
                            toInstance:(ALCModelObjectInstance *) instance
                            returnType:(Class) returnType
                      argumentMatchers:(NSArray *) argumentMatchers;

@end
