//
//  ALCAbstractPropertiesFacade.m
//  Alchemic
//
//  Created by Derek Clarkson on 29/8/16.
//  Copyright © 2016 Derek Clarkson. All rights reserved.
//

@import StoryTeller;

#import <Alchemic/ALCAbstractValueStore.h>

#import <Alchemic/ALCRuntime.h>
#import <Alchemic/ALCInternalMacros.h>
#import <Alchemic/ALCValueStoreImplementation.h>

NS_ASSUME_NONNULL_BEGIN

@implementation ALCAbstractValueStore {
    NSArray *_kvoProperties;
    BOOL _loadingData;
}

-(void) dealloc {
    STLog([self class], @"deallocing");
    for (NSString *prop in _kvoProperties) {
        [self removeObserver:self forKeyPath:prop];
    }
}

-(void) alchemicDidInjectDependencies {
    
    // Load default values then current values into the store.
    [self loadData:self.backingStoreDefaults];
    [self loadData:self.backingStoreValues];
    
    // Now start watching all writable properties for changes mde by the app.
    _kvoProperties = [ALCRuntime writeablePropertiesForClass:[self class]];
    for (NSString *prop in _kvoProperties) {
        STLog(self, @"Watching property %@", prop);
        [self addObserver:self forKeyPath:prop options:NSKeyValueObservingOptionNew context:nil];
    }
}

#pragma mark - Backing store override points

-(nullable NSDictionary<NSString *, id> *) backingStoreDefaults {
    return nil;
}

-(nullable NSDictionary<NSString *, id> *) backingStoreValues {
    return nil;
}

-(void) setBackingStoreValue:(nullable id) value forKey:(NSString *)key {}

-(nullable id) backingStoreValueForKey:(id) key {
    methodReturningObjectNotImplemented;
}

-(void)backingStoreDidUpdateValue:(nullable id) value forKey:(NSString *) key {
    _loadingData = YES;
    [self setValue:value forKey:key];
    _loadingData = NO;
}

#pragma mark - KVO

-(void) observeValueForKeyPath:(nullable NSString *) keyPath
                      ofObject:(nullable id) object
                        change:(nullable NSDictionary<NSKeyValueChangeKey,id> *) change
                       context:(nullable void *) context {
    
    if (!_loadingData) {
        // If we are not loading data from the backing store, then KVO has picked up a value being set, so forward to the backing store.
        id value = change[NSKeyValueChangeNewKey];
        id finalValue = [self backingStoreValueFromValue:value usingTransformerForKey:keyPath];
        STLog(self, @"Forwarding value for key '%@' to backing store", keyPath);
        [self setBackingStoreValue:finalValue forKey:keyPath];
    }
}

#pragma mark - KVC

// Setting a value for a undefined key means that there is no property for it. But we still need to get it to the store.
-(void) setValue:(nullable id) value forUndefinedKey:(NSString *) key {
    if (!_loadingData) {
        STLog(self, @"Forwarding value for unknown key '%@' to backing store", key);
        id finalValue = [self backingStoreValueFromValue:value usingTransformerForKey:key];
        [self setBackingStoreValue:finalValue forKey:key];
    }
}

// Will be called when not using a custom class. Therefore we want to get the data from the backing store.
-(nullable id) valueForUndefinedKey:(NSString *)key {
    STLog(self, @"Value for unknown key %@ requested, getting value from backing store", key);
    id value = [self backingStoreValueForKey:key];
    return [self valueFromBackingStoreValue:value usingTransformerForKey:key];
}

#pragma mark - Subscripting.

-(id) objectForKeyedSubscript:(NSString *) key {
    return [self valueForKey:key];
}

-(void) setObject:(id) obj forKeyedSubscript:(NSString<NSCopying> *) key {
    [self setValue:obj forKey:(NSString *) key];
}

#pragma mark - Internal

-(void) loadData:(nullable NSDictionary *) source {
    
    NSMutableDictionary<NSString *, id> *data = [source mutableCopy];
    if (data) {
        
        // Convert any values that need it.
        [data enumerateKeysAndObjectsUsingBlock:^(NSString *key, id obj, BOOL *stop) {
            data[key] = [self valueFromBackingStoreValue:data[key] usingTransformerForKey:key];
        }];
        
        [self setValuesForKeysWithDictionary:data];
    }
    
}

-(id) valueFromBackingStoreValue:(id) value usingTransformerForKey:(NSString *) key  {
    SEL transformerSelector = NSSelectorFromString(str(@"%@FromBackingStoreValue:", key));
    return [self transformValue:value usingSelector:transformerSelector];
}

-(id) backingStoreValueFromValue:(id) value  usingTransformerForKey:(NSString *) key {
    SEL transformerSelector = NSSelectorFromString(str(@"backingStoreValueFrom%@:", key.capitalizedString));
    return [self transformValue:value usingSelector:transformerSelector];
}

-(id) transformValue:(id) value usingSelector:(SEL) selector {
    if ([self respondsToSelector:selector]) {
        return ( (id (*)(id, SEL, id)) objc_msgSend)(self, selector, value);
    }
    return value;
}

@end

NS_ASSUME_NONNULL_END
