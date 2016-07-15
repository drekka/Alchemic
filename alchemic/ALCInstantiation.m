//
//  ALCInstantiationResult.m
//  Alchemic
//
//  Created by Derek Clarkson on 9/03/2016.
//  Copyright © 2016 Derek Clarkson. All rights reserved.
//

@import StoryTeller;

#import <Alchemic/ALCInstantiation.h>
#import <Alchemic/AlchemicAware.h>
#import <Alchemic/ALCDefs.h>
#import <Alchemic/ALCTypeDefs.h>
#import <Alchemic/NSObject+Alchemic.h>
#import <Alchemic/ALCRuntime.h>

NS_ASSUME_NONNULL_BEGIN

@implementation ALCInstantiation {
    ALCBlockWithObject _completion;
}

+(instancetype) instantiationWithObject:(nullable id) object completion:(nullable ALCBlockWithObject) completion {
    ALCInstantiation *instantiation = [[ALCInstantiation alloc] init];
    instantiation->_object = object;
    instantiation->_completion = completion;
    return instantiation;
}

-(void) addCompletion:(nullable ALCBlockWithObject) newCompletion {
    
    // Exit if there is nothing to add.
    if (!newCompletion) {
        return;
    }
    
    if (_completion) {
        ALCBlockWithObject currentCompletion = _completion;
        _completion = ^(id object) {
            currentCompletion(object);
            newCompletion(object);
        };
    } else {
        _completion = newCompletion;
    }
}


-(void) complete {
    [_object executeInjectionBlock:^(id object) {
        
        // If there is a completion block then call it.
        if (self->_object) {

            [ALCRuntime executeBlock:self->_completion withObject:(id) self->_object];
            
            // Now tell everyone the object has been instantiated.
            STLog(self, @"Posting instantiation notification for %@", self);
            [[NSNotificationCenter defaultCenter] postNotificationName:AlchemicDidCreateObject
                                                                object:self
                                                              userInfo:@{AlchemicDidCreateObjectUserInfoObject: self}];
        }
    }];
     
}

@end

NS_ASSUME_NONNULL_END
