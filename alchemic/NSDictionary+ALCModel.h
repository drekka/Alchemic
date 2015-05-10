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

@interface NSDictionary (ALCModel)

#pragma mark - Finding Metadata

-(id<ALCObjectMetadata>) metadataForObject:(id) object;

-(id<ALCObjectMetadata>) metedataForClass:(Class) class withName:(NSString *) name;

-(NSSet *) metadataWithMatchers:(NSSet *) matchers;

#pragma mark - Finding objects

-(NSSet *) objectsWithMatcherArgs:(id) firstMatcher, ...;

-(NSSet *) objectsWithMatchers:(NSSet *) matchers;

#pragma mark - Adding new Metadata

-(ALCInstance *) addInstanceForClass:(Class) class inContext:(ALCContext *) context;

-(ALCInstance *) addInstanceForClass:(Class) class inContext:(ALCContext *) context withName:(NSString *) name;

-(ALCInstance *) addObject:(id) finalObject inContext:(ALCContext *) context withName:(NSString *) name;

-(ALCFactoryMethod *) addFactoryMethod:(SEL) factorySelector
                            toInstance:(ALCInstance *) instance
                            returnType:(Class) returnType;

@end
