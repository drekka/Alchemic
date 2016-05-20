//
//  ALCInstantiationResult.m
//  Alchemic
//
//  Created by Derek Clarkson on 9/03/2016.
//  Copyright © 2016 Derek Clarkson. All rights reserved.
//

#import <StoryTeller/StoryTeller.h>

#import <Alchemic/ALCInstantiation.h>
#import <Alchemic/AlchemicAware.h>
#import <Alchemic/ALCDefs.h>

NS_ASSUME_NONNULL_BEGIN

@implementation ALCInstantiation {
    ALCObjectCompletion _completion;
}

+(instancetype) instantiationWithObject:(id) object completion:(nullable ALCObjectCompletion) completion {
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
    if (_completion) {
        STLog(_object, @"Executing completing for %@", _object);
        _completion(_object);
    }
    
    if ([_object conformsToProtocol:@protocol(AlchemicAware)]) {
        STLog(_object, @"Telling %@ it's injections have finished", _object);
        [(id<AlchemicAware>)_object alchemicDidInjectDependencies];
    }
    
    STLog(_object, @"Posting injections finished notification for %@", _object);
    [[NSNotificationCenter defaultCenter] postNotificationName:AlchemicDidCreateObject
                                                        object:self
                                                      userInfo:@{AlchemicDidCreateObjectUserInfoObject: _object}];
}

@end

NS_ASSUME_NONNULL_END
