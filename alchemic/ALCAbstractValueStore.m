//
//  ALCAbstractPropertiesFacade.m
//  Alchemic
//
//  Created by Derek Clarkson on 29/8/16.
//  Copyright © 2016 Derek Clarkson. All rights reserved.
//

@import StoryTeller;
#import "ALCAbstractValueStore.h"

#import <Alchemic/ALCRuntime.h>
#import <Alchemic/ALCInternalMacros.h>

NS_ASSUME_NONNULL_BEGIN

@implementation ALCAbstractValueStore {
    NSArray *_watchedProperties;
    BOOL _settingLocalValueOnly;
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
        [self setValuesForKeysWithDictionary:defaults];
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

-(void) updateLocalValue:(id) value forKey:(NSString *) key {
    _settingLocalValueOnly = YES;
    [super setValue:value forKey:key];
    _settingLocalValueOnly = NO;
}

#pragma mark - Override points

-(nullable NSDictionary<NSString *, id> *) loadDefaults {
    return nil;
}

-(void)valueStoreSetValue:(nullable id)value forKey:(NSString *)keyPath {}

-(nullable id) valueStoreValueForKey:(id) key {
    methodReturningObjectNotImplemented;
}

#pragma mark - KVO

// Triggered when setting properties.
-(void)observeValueForKeyPath:(nullable NSString *)keyPath
                     ofObject:(nullable id)object
                       change:(nullable NSDictionary<NSKeyValueChangeKey,id> *)change
                      context:(nullable void *)context {

    // Derived class property setters will trigger the KVO watch.
    STLog(self, @"Value set for key: %@: %@", keyPath, change[NSKeyValueChangeNewKey]);
    
    // Only pass to the store if we are not just updating the local value.
    if (!_settingLocalValueOnly) {
        [self valueStoreSetValue:change[NSKeyValueChangeNewKey] forKey:keyPath];
    }
}

#pragma mark - KVC

-(void) setValue:(nullable id) value forUndefinedKey:(NSString *)key {
    STLog(self, @"Unknowing key being set via KVC: %@", key);
    // Do nothing. ie. ignore settings we don't know about. Simply because the user may not have defined a property for the key.
}

-(nullable id) valueForKey:(NSString *)key {
    return [self valueStoreValueForKey:key];
}

// KVC method called by subscripting.
-(void) setValue:(nullable id) value forKey:(NSString *)key {
    
    STLog(self, @"Setting new value for key %@", key);
    
    // Pass the value to the store.
    [self valueStoreSetValue:value forKey:key];
    
    // Call super to ensure value is set on any declared properties. Also triggers KVO watch above if the key is being watched.
    [self updateLocalValue:value forKey:key];
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
