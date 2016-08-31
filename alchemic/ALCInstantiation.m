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

-(void) complete {
    [ALCRuntime executeBlock:^(id object) {
        
        [ALCRuntime executeBlock:self->_completion withObject:object];
        
        // Now tell everyone the object has been instantiated.
        STLog(self, @"Posting instantiation notification for a %@", NSStringFromClass([self.object class]));
        [[NSNotificationCenter defaultCenter] postNotificationName:AlchemicDidCreateObject
                                                            object:self
                                                          userInfo:@{AlchemicDidCreateObjectUserInfoObject: object}];
    }
                  withObject:_object];
    
}

@end

NS_ASSUME_NONNULL_END
