//
//  ALCApplicationDelegatePreResolveFilter.m
//  Alchemic
//
//  Created by Derek Clarkson on 22/8/16.
//  Copyright © 2016 Derek Clarkson. All rights reserved.
//

@import UIKit;
@import StoryTeller;

#import <Alchemic/ALCApplicationDelegateAspect.h>

#import <Alchemic/ALCModel.h>
#import <Alchemic/ALCMacros.h>
#import <Alchemic/ALCType.h>

@implementation ALCApplicationDelegateAspect {
    ALCClassObjectFactory *_appDelegateFactory;
}

+(BOOL) enabled {
    // Aspect is always active.
    return YES;
}

+(void) setEnabled:(BOOL) enabled {}

-(void) modelWillResolve:(id<ALCModel>) model {

    // First check and ensure any pre-registered app delegate is set to a reference type for later injection.
    for (ALCClassObjectFactory *objectFactory in model.classObjectFactories) {
        if ([objectFactory.type.objcClass conformsToProtocol:@protocol(UIApplicationDelegate)]) {
            STLog(self, @"Found pre-registered app delegate factory: %@", NSStringFromClass(objectFactory.type.objcClass));
            self->_appDelegateFactory = objectFactory;
            break;
        }
    }
    
    // If there is an app delegate factory but no app delegate then throw an error.
    id delegate = UIApplication.sharedApplication.delegate;
    if (!delegate) {
        if (_appDelegateFactory) {
            throwException(AlchemicResolvingException, @"Expected app delegate");
        }

        // No app delegate so don't configure one.
        return;
    }

    // If there is no pre-registered app delegate then set it up.
    if (!_appDelegateFactory) {
        ALCType *appDelegateType = [ALCType typeWithClass:[delegate class]];
        _appDelegateFactory = [[ALCClassObjectFactory alloc] initWithType:appDelegateType];
        STLog(self, @"Registering app delegate with class: %@", NSStringFromClass(appDelegateType.objcClass));
        [model addObjectFactory:_appDelegateFactory withName:nil];
    }

    [_appDelegateFactory configureWithOptions:@[AcReference] model:model];
}

-(void) modelDidResolve:(id<ALCModel>) model {
    if (_appDelegateFactory) {
        id delegate = [UIApplication sharedApplication].delegate;
        if (delegate) {
            STLog(self, @"Setting app delegate instance in model ...");
            [_appDelegateFactory storeObject:delegate];
        }
    }
}

@end
