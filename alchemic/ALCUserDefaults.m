//
//  ALCUSerDefaults.m
//  Alchemic
//
//  Created by Derek Clarkson on 22/8/16.
//  Copyright © 2016 Derek Clarkson. All rights reserved.
//

@import StoryTeller;

#import <Alchemic/ALCUserDefaults.h>

NS_ASSUME_NONNULL_BEGIN

@implementation ALCUserDefaults

-(nullable NSDictionary<NSString *, id> *) backingStoreDefaults {

    NSString *settingsBundle = [[NSBundle mainBundle] pathForResource:@"Settings" ofType:@"bundle"];
    if(!settingsBundle) {
        STLog(self, @"Settings.bundle not found");
        return nil;
    }
    
    NSDictionary *rootPlist = [NSDictionary dictionaryWithContentsOfFile:[settingsBundle stringByAppendingPathComponent:@"Root.plist"]];
    NSArray *preferences = rootPlist[@"PreferenceSpecifiers"];
    
    NSMutableDictionary *settings = [[NSMutableDictionary alloc] initWithCapacity:[preferences count]];
    for (NSDictionary *pref in preferences) {
        NSString *key = pref[@"Key"];
        if(key) {
            settings[key] = pref[@"DefaultValue"];
        }
    }
    
    [[NSUserDefaults standardUserDefaults] registerDefaults:settings];
    return settings;
}

-(nullable NSDictionary<NSString *,id> *) backingStoreValues {
    return [[NSUserDefaults standardUserDefaults] dictionaryRepresentation];
}

-(void)setBackingStoreValue:(nullable id)value forKey:(NSString *)key {
    [[NSUserDefaults standardUserDefaults] setValue:value forKey:key];
}

-(nullable id) backingStoreValueForKey:(id) key {
    return [[NSUserDefaults standardUserDefaults] valueForKey:key];
}

@end

NS_ASSUME_NONNULL_END
