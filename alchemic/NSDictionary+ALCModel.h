//
//  NSDictionary+ALCModel.h
//  alchemic
//
//  Created by Derek Clarkson on 23/03/2015.
//  Copyright (c) 2015 Derek Clarkson. All rights reserved.
//

@import Foundation;

#import "ALCObjectMetadata.h"

@class ALCContext;
@class ALCInstance;
@class ALCFactoryMethod;

#import "ALCMatcher.h"

@interface NSDictionary (ALCModel)

#pragma mark - Finding Metadata

-(ALCInstance *) instanceForObject:(id) object;

-(NSSet *) metadataWithMatchers:(NSSet *) matchers;

-(NSSet *) metadataWithMatcher:(id<ALCMatcher>) matcher;

#pragma mark - Finding objects

-(NSSet *) objectsWithMatcherArgs:(id) firstMatcher, ...;

-(NSSet *) objectsWithMatchers:(NSSet *) matchers;

#pragma mark - Adding new Metadata

-(void) indexMetadata:(id<ALCObjectMetadata>) objectMetadata underName:(NSString *) name;

-(ALCInstance *) addInstanceForClass:(Class) class inContext:(ALCContext *) context;

-(ALCInstance *) addInstanceForClass:(Class) class inContext:(ALCContext *) context withName:(NSString *) name;

-(ALCInstance *) addObject:(id) finalObject inContext:(ALCContext *) context withName:(NSString *) name;

-(ALCFactoryMethod *) addFactoryMethod:(SEL) factorySelector
                            toInstance:(ALCInstance *) instance
                            returnType:(Class) returnType
                      argumentMatchers:(NSArray *) argumentMatchers;

@end
