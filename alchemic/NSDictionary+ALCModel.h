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
@class ALCObjectInstance;
@class ALCFactoryMethod;

#import "ALCMatcher.h"

@interface NSDictionary (ALCModel)

#pragma mark - Finding Metadata

-(ALCObjectInstance *) instanceForObject:(id) object;

-(NSSet *) metadataWithMatchers:(NSSet *) matchers;

-(NSSet *) metadataWithMatcher:(id<ALCMatcher>) matcher;

#pragma mark - Finding objects

-(NSSet *) objectsWithMatcherArgs:(id) firstMatcher, ...;

-(NSSet *) objectsWithMatchers:(NSSet *) matchers;

#pragma mark - Adding new Metadata

-(void) indexMetadata:(id<ALCModelObject>) objectMetadata underName:(NSString *) name;

-(ALCObjectInstance *) addInstanceForClass:(Class) class inContext:(ALCContext *) context;

-(ALCObjectInstance *) addInstanceForClass:(Class) class inContext:(ALCContext *) context withName:(NSString *) name;

-(ALCObjectInstance *) addObject:(id) finalObject inContext:(ALCContext *) context withName:(NSString *) name;

-(ALCFactoryMethod *) addFactoryMethod:(SEL) factorySelector
                            toInstance:(ALCObjectInstance *) instance
                            returnType:(Class) returnType
                      argumentMatchers:(NSArray *) argumentMatchers;

@end
