//
//  ALCObjectStore.h
//  alchemic
//
//  Created by Derek Clarkson on 9/03/2015.
//  Copyright (c) 2015 Derek Clarkson. All rights reserved.
//

@import Foundation;

@class ALCClassInfo;
@class ALCContext;

/**
 Storage area for objects which have been registered with Alchemic or are regarded as dependencies.
 */
@interface ALCObjectStore : NSObject

/**
 All the objects in the store.
 */
@property (nonatomic, strong, readonly) NSArray *objects;

#pragma mark - Lifecycle

/**
 Main intialiser.
 
 @param context a passe context.
 
 @return an instance of this class.
 */
-(instancetype) initWithContext:(__weak ALCContext *) context;

/**
 Creates all registered singleton objects.
 */
-(void) instantiateSingletons;

#pragma mark - Adding objects

/**
 Adds a proxy which will be instantiated via factories at a later time.
 
 @see addLazyInstantiationForClass:withName:
 @param classInfo the class info that describes the object to be created later.
 */
-(void) addLazyInstantionForClass:(ALCClassInfo *) classInfo;

/**
 Adds a proxy which will be instantiated via factories at a later time.
 
 @param classInfo the class info that describes the object to be created.
 @param name      the name under which the object will be stored.
 */
-(void) addLazyInstantionForClass:(ALCClassInfo *) classInfo withName:(NSString *) name;

/**
 Adds an object to the store.
 @discussion By default this calls addObject:withName: using the objects class as the name.
 
 @param object the object to be added.
 
 */
-(void) addObject:(id) object;

/**
 Adds an obejct to the store under a specific name.
 
 @param object the object to add.
 @param name   the name to store the object under. Names are not unique and many objects can be stored under the same name. Using a specific name allows you to store objects in a way that they can be found when there are many with the same class or protocol.
 */
-(void) addObject:(id) object withName:(NSString *) name;

#pragma mark - Querying

/**
 Returns a list of objects that match the class.
 
 @param aClass the class to find. Can match more than one object.
 
 @return a list of found objects.
 */
-(NSArray *) objectsOfClass:(Class) aClass;

/**
 Returns a list of objects that implement a specific protocol.
 
 @param protocol the protocol to search for.
 
 @return a list of found objects.
 */
-(NSArray *) objectsWithProtocol:(Protocol *) protocol;

/**
 Return a list of objects with the passed name.
 
 @param name the name to find.
 
 @return a list of objects.
 */
-(NSArray *) objectsWithName:(NSString *) name;

@end
