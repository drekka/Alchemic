//
//  ALCObjectStore.h
//  alchemic
//
//  Created by Derek Clarkson on 9/03/2015.
//  Copyright (c) 2015 Derek Clarkson. All rights reserved.
//

@import Foundation;

/**
 Storage area for objects which have been registered with Alchemic or are regarded as dependencies.
 */
@interface ALCObjectStore : NSObject

/**
 Adds an object.
 @param object the object to be added.
 */
-(void) addObject:(id) object;

-(NSArray *) objectsOfClass:(Class) aClass;

-(NSArray *) objectsWithProtocol:(Protocol *) protocol;

-(NSArray *) objectsWithSelector:(SEL) selector;

+(NSArray *) objectsInArray:(NSArray *) array withProtocol:(Protocol *) protocol;

+(NSArray *) objectsInArray:(NSArray *) array withSelector:(SEL) selector;

@end
