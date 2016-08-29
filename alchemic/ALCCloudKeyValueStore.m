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
    
    [[NSNotificationCenter defaultCenter] addObserverForName:NSUbiquitousKeyValueStoreDidChangeExternallyNotification object:nil queue:nil usingBlock:^(NSNotification * _Nonnull note) {
    }];
    
    // get changes that might have happened while this instance of your app wasn't running
    [[NSUbiquitousKeyValueStore defaultStore] synchronize];
    return [[NSUbiquitousKeyValueStore defaultStore] dictionaryRepresentation];
}

-(void)valueStoreSetValue:(nullable id)value forKey:(NSString *)key {
    [[NSUbiquitousKeyValueStore defaultStore] setValue:value forKey:key];
}

-(nullable id) valueStoreValueForKey:(id) key {
    return [[NSUbiquitousKeyValueStore defaultStore] valueForKey:key];
}

@end

NS_ASSUME_NONNULL_END
