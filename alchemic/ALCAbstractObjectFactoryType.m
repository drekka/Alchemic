//
//  ALCAbstractObjectFactoryType.m
//  Alchemic
//
//  Created by Derek Clarkson on 20/06/2016.
//  Copyright © 2016 Derek Clarkson. All rights reserved.
//

#import "ALCAbstractObjectFactoryType.h"

NS_ASSUME_NONNULL_BEGIN

@implementation ALCAbstractObjectFactoryType {
    __weak id _weakObjectRef;
    id _strongObjectRef;
}

@synthesize weak = _weak;

#pragma mark - Override properties

-(ALCFactoryType) type {
    return ALCFactoryTypeSingleton;
}

-(void)setObject:(id) object {
    if (_weak) {
        _weakObjectRef = object;
    } else {
        _strongObjectRef = object;
    }
}

-(id) object {
    return _weak ? _weakObjectRef : _strongObjectRef;
}

-(BOOL) isReady {
    [self doesNotRecognizeSelector:_cmd];
    return NO;
}

@end

NS_ASSUME_NONNULL_END
