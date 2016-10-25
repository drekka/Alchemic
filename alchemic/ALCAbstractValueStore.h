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
 Abstract parent class for classes that can act as facades for various properties systems. For example user defaults or cloud key value stores.
 
 This class provides services to KVO watch properties in extended classes and automatically update the backing storage mechanism and provides subscript based access to data.
 
 It's designed to act as a local copy of the original store which is referred to as the backing store.
 
 */
@interface ALCAbstractValueStore : NSObject<AlchemicAware>

#pragma mark - Backing store override points

/**
 Retruns the default values to initialize this store with.
 
 For example, from a root.plist file.
 */
@property (nonatomic, strong, nullable, readonly) NSDictionary<NSString *, id> *backingStoreDefaults;

/**
 Call when your backing store updates a value.
 
 This will then update this stores data without triggering an recursive update back to the backing store.
 */
-(void) backingStoreDidUpdateValue:(nullable id)value forKey:(NSString *)key;

/**
 Override to save a new value to the backing store.
 
 @param value The value to be saved.
 @param key The key within the backing store to save under.
 */
-(void) setBackingStoreValue:(nullable id)value forKey:(NSString *)key;

/**
 Override to retrieve a value from the backing store.
 
 @param key The key within the backing store.
 */
-(nullable id) backingStoreValueForKey:(id) key;

#pragma mark - Subscripting services.

-(id) objectForKeyedSubscript:(NSString *) key;

-(void) setObject:(id) obj forKeyedSubscript:(NSString<NSCopying> *) key;

@end

NS_ASSUME_NONNULL_END
