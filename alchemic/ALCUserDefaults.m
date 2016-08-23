//
//  ALCUSerDefaults.m
//  Alchemic
//
//  Created by Derek Clarkson on 22/8/16.
//  Copyright © 2016 Derek Clarkson. All rights reserved.
//

#import "ALCUserDefaults.h"
@import StoryTeller;

#import <Alchemic/ALCMacros.h>
#import <Alchemic/ALCRuntime.h>

@implementation ALCUserDefaults {
    NSArray *_watchedProperties;
}

-(void)dealloc {
    STLog([self class], @"deallocing");
    for (__unused NSString *prop in _watchedProperties) {
       [self removeObserver:self forKeyPath:prop];
    }
}

-(void) alchemicDidInjectDependencies {
    [self loadRootPlist];
    [self kvoWatchProperties];
}

-(void) loadRootPlist {
    NSString *settingsBundle = [[NSBundle mainBundle] pathForResource:@"Settings" ofType:@"bundle"];
    if(!settingsBundle) {
        STLog(self, @"Settings.bundle not found");
        return;
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
    
    // Also load properties in derived classes.
    [self setValuesForKeysWithDictionary:settings];
}

-(void) kvoWatchProperties {
    _watchedProperties = [ALCRuntime writeablePropertiesForClass:[self class]];
    for (NSString *prop in _watchedProperties) {
        [self addObserver:self forKeyPath:prop options:NSKeyValueObservingOptionNew context:nil];
    }
}

#pragma mark - KVO

-(void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context {
    // Derived class property setters will trigger the KVO watch.
    STLog(self, @"Setting user default value for key: %@", keyPath);
    [[NSUserDefaults standardUserDefaults] setValue:change[NSKeyValueChangeNewKey] forKey:keyPath];
}

#pragma mark - KVC

-(void) setValue:(id)value forUndefinedKey:(NSString *)key {
    STLog(self, @"Unknowing key being set via KVC: %@", key);
    // Do nothing. ie. ignore settings we don't know about. Simply because the user may not have defined a property for the key.
}

-(id) valueForKey:(NSString *)key {
    return [[NSUserDefaults standardUserDefaults] valueForKey:key];
}

-(void) setValue:(id)value forKey:(NSString *)key {

    STLog(self, @"Setting new value for key %@", key);
    
    // If the key is not in the watched properties list then KVO will not trigger to set user default.
    if (![_watchedProperties containsObject:key]) {
        [[NSUserDefaults standardUserDefaults] setValue:value forKey:key];
    }
    
    // Call super to ensure value is set on any declared properties. Also triggers KVO calls.
    [super setValue:value forKey:key];
}

#pragma mark - Subscripting.

-(id) objectForKeyedSubscript:(NSString *) key {
    return [self valueForKey:key];
}

-(void) setObject:(id) obj forKeyedSubscript:(NSString<NSCopying> *) key {
    [self setValue:obj forKey:(NSString *) key];
}
@end
