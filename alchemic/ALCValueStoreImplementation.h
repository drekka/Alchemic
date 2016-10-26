//
//  ALCValueStoreImplementation.h
//  Alchemic
//
//  Created by Derek Clarkson on 26/10/16.
//  Copyright © 2016 Derek Clarkson. All rights reserved.
//

@import Foundation;

NS_ASSUME_NONNULL_BEGIN

@protocol ALCValueStoreImplementation <NSObject>

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

@end

NS_ASSUME_NONNULL_END
