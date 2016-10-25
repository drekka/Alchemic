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
    NSArray *_kvoProperties;
    BOOL _settingValues;
}

-(void)dealloc {
    STLog([self class], @"deallocing");
    for (NSString *prop in _kvoProperties) {
        [self removeObserver:self forKeyPath:prop];
    }
}

-(void) alchemicDidInjectDependencies {
    NSDictionary<NSString *, id> *defaults = self.backingStoreDefaults;
    if (defaults) {
        _settingValues = YES;
        [self setValuesForKeysWithDictionary:defaults];
        _settingValues = NO;
    }

    // Now start watching all writable properties.
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

-(void)setBackingStoreValue:(nullable id) value forKey:(NSString *)key {}

-(nullable id) backingStoreValueForKey:(id) key {
    methodReturningObjectNotImplemented;
}

-(void)backingStoreDidUpdateValue:(nullable id)value forKey:(NSString *)key {
    _settingValues = YES;
    [self setValue:value forKey:key];
    _settingValues = NO;
}

#pragma mark - KVO

-(void)observeValueForKeyPath:(nullable NSString *)keyPath
                     ofObject:(nullable id)object
                       change:(nullable NSDictionary<NSKeyValueChangeKey,id> *)change
                      context:(nullable void *)context {

    // If we are not loading, then KVO has picked up a value being set, so ensure the backing store has it.
    if (!_settingValues) {
        id value = change[NSKeyValueChangeNewKey];
        id finalValue = [self transformValue:value forKey:keyPath direction:@"To"];
        STLog(self, @"Value changed for key: %@: %@", keyPath, finalValue);
        [self setBackingStoreValue:finalValue forKey:keyPath];
    }
}

#pragma mark - KVC

// Setting a value for a undefined key means that there is no property for it. But we still need to get it to the store.
-(void) setValue:(nullable id) value forUndefinedKey:(NSString *)key {
    STLog(self, @"Undefined key %@ passing value to backing store", key);
    if (!_settingValues) {
        id finalValue = [self transformValue:value forKey:key direction:@"To"];
        [self setBackingStoreValue:finalValue forKey:key];
    }
}

// Will be called when not using a custom class. Therefore we want to get the data from the backing store.
-(nullable id) valueForUndefinedKey:(NSString *)key {
    STLog(self, @"Undefined key %@ getting value from backing store", key);
    id value = [self backingStoreValueForKey:key];
    return [self transformValue:value forKey:key direction:@"From"];
}

#pragma mark - Subscripting.

-(id) objectForKeyedSubscript:(NSString *) key {
    return [self valueForKey:key];
}

-(void) setObject:(id) obj forKeyedSubscript:(NSString<NSCopying> *) key {
    [self setValue:obj forKey:(NSString *) key];
}

#pragma mark - Internal

-(id) transformValue:(id) value forKey:(NSString *) key direction:(NSString *) direction {
    SEL transformerSelector = NSSelectorFromString(str(@"%@valueTransformer%@Cloud:", key, direction));
    id transformedValue = value;
    if ([self respondsToSelector:transformerSelector]) {
        transformedValue = ( (id (*)(id, SEL, id)) objc_msgSend)(self, transformerSelector, value);
    }
    return transformedValue;
}

@end

NS_ASSUME_NONNULL_END
