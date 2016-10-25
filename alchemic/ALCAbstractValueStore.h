//
//  ALCAbstractPropertiesFacade.h
//  Alchemic
//
//  Created by Derek Clarkson on 29/8/16.
//  Copyright © 2016 Derek Clarkson. All rights reserved.
//

@import Foundation;
#import <Alchemic/AlchemicAware.h>

NS_ASSUME_NONNULL_BEGIN

/**
 Abstract parent class for classes that can act as facades fro various properties systems. For example user defaults or cloud key value stores.
 
 This class provides services to KVO watch properties in extended classes and automatically update the backing storage mechanism and provides subscript based access to data.
 
 */
@interface ALCAbstractValueStore : NSObject<AlchemicAware>

#pragma mark - Override points

/**
 Retrive the defaults for loading into the stored properties.
 */
-(nullable NSDictionary<NSString *, id> *) loadDefaults;

/**
 Call when your backing store updates a value independantly of this store.
 
 This will then update this stores data without triggering an upload back to the store.
 */
-(void)valueStoreDidUpdateValue:(nullable id)value forKey:(NSString *)key;

/**
 Override to save a new value to the backing store.
 
 @param value The value to be saved.
 @param key The key within the backing store to save under.
 */
-(void)valueStoreSetValue:(nullable id)value forKey:(NSString *)key;

/**
 Override to retrieve a value from the backing store.
 
 @param key The key within the backing store.
 */
-(nullable id) valueStoreValueForKey:(id) key;

#pragma mark - Updating local values

#pragma mark - Subscripting services.

-(id) objectForKeyedSubscript:(NSString *) key;

-(void) setObject:(id) obj forKeyedSubscript:(NSString<NSCopying> *) key;

@end

NS_ASSUME_NONNULL_END
