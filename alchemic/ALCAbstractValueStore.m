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

NS_ASSUME_NONNULL_BEGIN

@implementation ALCAbstractValueStore {
    NSArray *_watchedProperties;
    BOOL _loadingData;
}

-(void)dealloc {
    STLog([self class], @"deallocing");
    for (NSString *prop in _watchedProperties) {
        [self removeObserver:self forKeyPath:prop];
    }
}

-(void) alchemicDidInjectDependencies {
    NSDictionary<NSString *, id> *defaults = [self loadDefaults];
    if (defaults) {
        _loadingData = YES;
        [self setValuesForKeysWithDictionary:defaults];
        _loadingData = NO;
    }
    [self kvoWatchProperties];
}

-(void) kvoWatchProperties {
    _watchedProperties = [ALCRuntime writeablePropertiesForClass:[self class]];
    for (NSString *prop in _watchedProperties) {
        STLog(self, @"Watching property %@", prop);
        [self addObserver:self forKeyPath:prop options:NSKeyValueObservingOptionNew context:nil];
    }
}

#pragma mark - Override points

-(nullable NSDictionary<NSString *, id> *) loadDefaults {
    return nil;
}

-(void)valueStoreSetValue:(nullable id)value forKey:(NSString *)key {}

-(nullable id) valueStoreValueForKey:(id) key {
    methodReturningObjectNotImplemented;
}

-(void)valueStoreDidUpdateValue:(nullable id)value forKey:(NSString *)key {
    _loadingData = YES;
    [self setValue:value forKey:key];
    _loadingData = NO;
}

#pragma mark - KVO

// Triggered when setting autowatched properties.
-(void)observeValueForKeyPath:(nullable NSString *)keyPath
                     ofObject:(nullable id)object
                       change:(nullable NSDictionary<NSKeyValueChangeKey,id> *)change
                      context:(nullable void *)context {
    STLog(self, @"Value set for key: %@: %@", keyPath, change[NSKeyValueChangeNewKey]);
    if (!_loadingData) {
        [self valueStoreSetValue:change[NSKeyValueChangeNewKey] forKey:keyPath];
    }
}

#pragma mark - KVC

// Setting a value for a undefined key means that there is no property for it. But we still need to get it to the store.
-(void) setValue:(nullable id) value forUndefinedKey:(NSString *)key {
    STLog(self, @"Undefined key %@ passing value to backing store", key);
    if (!_loadingData) {
        [self valueStoreSetValue:value forKey:key];
    }
}

// Will be called when not using a custom class. Therefore we want to get the data from the backing store.
-(nullable id) valueForUndefinedKey:(NSString *)key {
    STLog(self, @"Undefined key %@ getting value from backing store", key);
    return [self valueStoreValueForKey:key];
}

#pragma mark - Subscripting.

-(id) objectForKeyedSubscript:(NSString *) key {
    return [self valueForKey:key];
}

-(void) setObject:(id) obj forKeyedSubscript:(NSString<NSCopying> *) key {
    [self setValue:obj forKey:(NSString *) key];
}
@end

NS_ASSUME_NONNULL_END
