//
//  ALCApplicationDelegatePreResolveFilter.m
//  Alchemic
//
//  Created by Derek Clarkson on 22/8/16.
//  Copyright © 2016 Derek Clarkson. All rights reserved.
//

@import UIKit;
@import StoryTeller;

#import "ALCApplicationDelegateAspect.h"

#import <Alchemic/ALCModel.h>
#import <Alchemic/ALCMacros.h>
#import <Alchemic/ALCClassObjectFactory.h>

@implementation ALCApplicationDelegateAspect {
    ALCClassObjectFactory *_appDelegateFactory;
}

+(void) setEnabled:(BOOL) enabled {}

+(BOOL) enabled {
    // Aspect is always active.
    return YES;
}

-(void) modelWillResolve:(id<ALCModel>) model {
    // Locate and store a reference to the UIApplicationDelegate if it exists.
    [model.classObjectFactories enumerateObjectsUsingBlock:^(ALCClassObjectFactory *objectFactory, NSUInteger idx, BOOL *stop) {
        if ([objectFactory.objectClass conformsToProtocol:@protocol(UIApplicationDelegate)]) {
            self->_appDelegateFactory = objectFactory;
            [objectFactory configureWithOptions:@[AcReference] model:model];
            *stop = YES;
        }
    }];
}

-(void) modelDidResolve:(id<ALCModel>) model {
    if (_appDelegateFactory) {
        id delegate = [UIApplication sharedApplication].delegate;
        if (delegate) {
            STLog(self, @"Injecting UIApplicationDelegate instance into model");
            [_appDelegateFactory setObject:delegate];
        }
    }
}

@end
