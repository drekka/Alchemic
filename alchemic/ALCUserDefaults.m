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

@implementation ALCUserDefaults

AcRegister(AcFactoryName(@"userDefaults"))

-(void) alchemicDidInjectDependencies {

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
}

-(id) valueForKey:(NSString *)key {
    return [[NSUserDefaults standardUserDefaults] valueForKey:key];
}

-(void) setValue:(id)value forKey:(NSString *)key {
    [[NSUserDefaults standardUserDefaults] setValue:value forKey:key];
}

@end
