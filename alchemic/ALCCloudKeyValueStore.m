//
//  ALCCloudKeyValueStore.m
//  Alchemic
//
//  Created by Derek Clarkson on 29/8/16.
//  Copyright © 2016 Derek Clarkson. All rights reserved.
//

#import "ALCCloudKeyValueStore.h"

@import StoryTeller;

#import "ALCMacros.h"
#import "ALCRuntime.h"

NS_ASSUME_NONNULL_BEGIN

@implementation ALCCloudKeyValueStore {
    id _storeDataChangedObserver;
}

-(void) dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:_storeDataChangedObserver];
}

-(void) alchemicDidInjectDependencies {

    [super alchemicDidInjectDependencies];

    // Start watching the store for changes.
    [[NSNotificationCenter defaultCenter] addObserverForName:NSUbiquitousKeyValueStoreDidChangeExternallyNotification object:nil queue:nil usingBlock:^(NSNotification *notification) {
        
        // If the store has changed, update the local properties with the passed keys.
        NSUInteger reason = ((NSNumber *)notification.userInfo[NSUbiquitousKeyValueStoreChangeReasonKey]).unsignedIntegerValue;
        if (reason == NSUbiquitousKeyValueStoreServerChange) {
            NSArray<NSString *> *keys = notification.userInfo[NSUbiquitousKeyValueStoreChangedKeysKey];
            for (NSString *key in keys) {
                STLog(self, @"Cloud updated value for %@", key);
                [self backingStoreDidUpdateValue:[self backingStoreValueForKey:key] forKey:key];
            }
        }
    }];
}

-(nullable NSDictionary<NSString *, id> *) backingStoreValues {
    [[NSUbiquitousKeyValueStore defaultStore] synchronize];
    return [[NSUbiquitousKeyValueStore defaultStore] dictionaryRepresentation];
}

-(void)setBackingStoreValue:(nullable id)value forKey:(NSString *)key {
    STLog(self, @"Sending value to cloud key %@: %@", key, value);
    [[NSUbiquitousKeyValueStore defaultStore] setObject:value forKey:key];
    [[NSUbiquitousKeyValueStore defaultStore] synchronize]; // Because it seems to take some time
}

-(nullable id) backingStoreValueForKey:(id) key {
    return [[NSUbiquitousKeyValueStore defaultStore] objectForKey:key];
}

@end

NS_ASSUME_NONNULL_END
