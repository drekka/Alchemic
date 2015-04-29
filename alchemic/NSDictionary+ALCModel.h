//
//  NSDictionary+ALCModel.h
//  alchemic
//
//  Created by Derek Clarkson on 23/03/2015.
//  Copyright (c) 2015 Derek Clarkson. All rights reserved.
//

@import Foundation;

#import "ALCInstance.h"

@interface NSDictionary (ALCModel)

#pragma mark - Finding instances.

-(ALCInstance *) instanceForObject:(id) object;

-(ALCInstance *) instanceForClass:(Class) class withName:(NSString *) name;

-(NSSet *) instancesWithMatchers:(NSSet *) matchers;

#pragma mark - Finding objects

-(NSSet *) objectsWithMatcherArgs:(id) firstMatcher, ...;

-(NSSet *) objectsWithMatchers:(NSSet *) matchers;

#pragma mark - Adding new instances

-(void) addInstance:(ALCInstance *) instance;

-(void) addObject:(id) finalObject withName:(NSString *) name;

@end
