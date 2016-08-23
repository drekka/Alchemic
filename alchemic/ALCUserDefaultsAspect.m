//
//  ALCUserDefaultsAspect.m
//  Alchemic
//
//  Created by Derek Clarkson on 23/8/16.
//  Copyright © 2016 Derek Clarkson. All rights reserved.
//

#import "ALCUserDefaultsAspect.h"

#import <Alchemic/ALCModel.h>
#import <Alchemic/ALCObjectFactory.h>
#import <Alchemic/ALCClassObjectFactory.h>
#import <Alchemic/ALCUserDefaults.h>

@implementation ALCUserDefaultsAspect

static BOOL _enabled;

+(void) setEnabled:(BOOL) enabled {
    _enabled = enabled;
}

+(BOOL) enabled {
    return _enabled;
}

-(void)modelWillResolve:(id<ALCModel>) model {
    
    // First look for a user defined user defaults.
    for (id<ALCObjectFactory> objectFactory in model.objectFactories) {
        if ([objectFactory.objectClass isSubclassOfClass:[ALCUserDefaults class]]) {
            // Nothing more to do.
            return;
        }
    }

    // No user defined defaults so set up ALCUserDefaults in the model.
    ALCClassObjectFactory *defaultsFactory = [[ALCClassObjectFactory alloc] initWithClass:[ALCUserDefaults class]];
    [model addObjectFactory:defaultsFactory withName:@"userDefaults"];
}

@end
