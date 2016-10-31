//
//  ALCUserDefaultsAspect.m
//  Alchemic
//
//  Created by Derek Clarkson on 23/8/16.
//  Copyright © 2016 Derek Clarkson. All rights reserved.
//

@import StoryTeller;

#import <Alchemic/ALCUserDefaultsAspect.h>

#import <Alchemic/ALCModel.h>
#import <Alchemic/ALCClassObjectFactory.h>
#import <Alchemic/ALCType.h>
#import <Alchemic/ALCUserDefaults.h>

@implementation ALCUserDefaultsAspect

-(void)modelWillResolve:(id<ALCModel>) model {
    
    // First look for a user defined user defaults already present in the model.
    for (id<ALCObjectFactory> objectFactory in model.objectFactories) {
        if ([objectFactory.type.objcClass isSubclassOfClass:[ALCUserDefaults class]]) {
            return;
        }
    }

    // No user defined defaults so set up ALCUserDefaults in the model.
    STLog(self, @"Adding default user defaults handling");
    ALCType *type = [ALCType typeWithClass:[ALCUserDefaults class]];
    ALCClassObjectFactory *defaultsFactory = [[ALCClassObjectFactory alloc] initWithType:type];
    [model addObjectFactory:defaultsFactory withName:@"userDefaults"];
}

@end
