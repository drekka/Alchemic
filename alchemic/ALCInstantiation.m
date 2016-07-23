//
//  ALCInstantiationResult.m
//  Alchemic
//
//  Created by Derek Clarkson on 9/03/2016.
//  Copyright © 2016 Derek Clarkson. All rights reserved.
//

@import StoryTeller;

#import "ALCInstantiation.h"
#import "AlchemicAware.h"
#import "ALCDefs.h"
#import "ALCTypeDefs.h"
#import "NSObject+Alchemic.h"
#import "ALCRuntime.h"

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
        STLog(self, @"Posting instantiation notification for %@", self);
        [[NSNotificationCenter defaultCenter] postNotificationName:AlchemicDidCreateObject
                                                            object:self
                                                          userInfo:@{AlchemicDidCreateObjectUserInfoObject: self}];
    }
                  withObject:_object];
    
}

@end

NS_ASSUME_NONNULL_END
