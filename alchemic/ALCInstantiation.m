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
#import <Alchemic/NSObject+Alchemic.h>

NS_ASSUME_NONNULL_BEGIN

@implementation ALCInstantiation {
    ALCObjectCompletion _completion;
}

+(instancetype) instantiationWithObject:(nullable id) object completion:(nullable ALCObjectCompletion) completion {
    ALCInstantiation *instantiation = [[ALCInstantiation alloc] init];
    instantiation->_object = object;
    instantiation->_completion = completion;
    return instantiation;
}

-(void) addCompletion:(nullable ALCObjectCompletion) newCompletion {
    
    // Exit if there is nothing to add.
    if (!newCompletion) {
        return;
    }
    
    if (_completion) {
        ALCObjectCompletion currentCompletion = _completion;
        _completion = ^(id object) {
            currentCompletion(object);
            newCompletion(object);
        };
    } else {
        _completion = newCompletion;
    }
}


-(void) complete {
    [_object completeWithBlock:_completion];
}

@end

NS_ASSUME_NONNULL_END
