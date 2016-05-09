//
//  ALCInstantiationResult.m
//  Alchemic
//
//  Created by Derek Clarkson on 9/03/2016.
//  Copyright © 2016 Derek Clarkson. All rights reserved.
//

#import "ALCInstantiation.h"
#import "AlchemicAware.h"


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

-(void) complete {
    if (_completion) {
        _completion(_object);
    }

    if ([_object conformsToProtocol:@protocol(AlchemicAware)]) {
        [(id<AlchemicAware>)_object alchemicDidInjectDependencies];
    }

    [[NSNotificationCenter defaultCenter] postNotificationName:AlchemicDidCreateObject
                                                        object:self
                                                      userInfo:@{AlchemicDidCreateObjectUserInfoObject: _object}];
}

@end

NS_ASSUME_NONNULL_END
