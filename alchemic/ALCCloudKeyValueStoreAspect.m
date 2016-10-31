//
//  ALCCloudKeyvValueStoreAspect.m
//  Alchemic
//
//  Created by Derek Clarkson on 29/8/16.
//  Copyright © 2016 Derek Clarkson. All rights reserved.
//

@import UIKit;
@import StoryTeller;

#import <Alchemic/ALCCloudKeyValueStoreAspect.h>

#import <Alchemic/ALCModel.h>
#import <Alchemic/ALCMacros.h>
#import <Alchemic/ALCClassObjectFactory.h>
#import <Alchemic/ALCCloudKeyValueStore.h>
#import <Alchemic/ALCType.h>

@implementation ALCCloudKeyValueStoreAspect

-(void)modelWillResolve:(id<ALCModel>) model {
    
    // First look for a user defined user defaults.
    for (id<ALCObjectFactory> objectFactory in model.objectFactories) {
        if ([objectFactory.type.objcClass isSubclassOfClass:[ALCCloudKeyValueStore class]]) {
            // Nothing more to do.
            return;
        }
    }
    
    // No user defined defaults so set up ALCUserDefaults in the model.
    STLog(self, @"Adding default cloud key value store");
    ALCClassObjectFactory *defaultsFactory = [[ALCClassObjectFactory alloc] initWithType:[ALCType typeWithClass:[ALCCloudKeyValueStore class]]];
    [model addObjectFactory:defaultsFactory withName:@"cloudKeyValueStore"];
}

@end
