//
//  ALCCloudKeyValueStore.m
//  Alchemic
//
//  Created by Derek Clarkson on 29/8/16.
//  Copyright © 2016 Derek Clarkson. All rights reserved.
//

#import "ALCCloudKeyValueStore.h"

@import StoryTeller;

#import <Alchemic/ALCMacros.h>
#import <Alchemic/ALCRuntime.h>

NS_ASSUME_NONNULL_BEGIN

@implementation ALCCloudKeyValueStore {
    id _storeDataChangedObserver;
}

-(void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:_storeDataChangedObserver];
}

-(nullable NSDictionary<NSString *, id> *) loadDefaults {
    
    [[NSNotificationCenter defaultCenter] addObserverForName:NSUbiquitousKeyValueStoreDidChangeExternallyNotification object:nil queue:nil usingBlock:^(NSNotification * _Nonnull notification) {
        
        // If the store has changed, update the local properties with the passed keys.
        NSUInteger reason = ((NSNumber *)notification.userInfo[NSUbiquitousKeyValueStoreChangeReasonKey]).unsignedIntegerValue;
        if (reason == NSUbiquitousKeyValueStoreServerChange) {
            NSArray<NSString *> *keys = notification.userInfo[NSUbiquitousKeyValueStoreChangedKeysKey];
            for (NSString *key in keys) {
                STLog(self, @"Cloud updated value for %@", key);
                [self updateLocalValue:[self valueStoreValueForKey:key] forKey:key];
            }
        }
    }];
    
    // get changes that might have happened while this instance of your app wasn't running
    [[NSUbiquitousKeyValueStore defaultStore] synchronize];
    return [[NSUbiquitousKeyValueStore defaultStore] dictionaryRepresentation];
}

-(void)valueStoreSetValue:(nullable id)value forKey:(NSString *)key {
    [[NSUbiquitousKeyValueStore defaultStore] setObject:value forKey:key];
}

-(nullable id) valueStoreValueForKey:(id) key {
    return [[NSUbiquitousKeyValueStore defaultStore] objectForKey:key];
}

@end

NS_ASSUME_NONNULL_END
