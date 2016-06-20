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

-(void)setObject:(id) object {
    if (self.isWeak) {
        _weakObjectRef = object;
    } else {
        _strongObjectRef = object;
    }
}

-(id) object {
    return self.isWeak ? _weakObjectRef : _strongObjectRef;
}

-(BOOL) ready {
    [self doesNotRecognizeSelector:_cmd];
    return NO;
}

@end

NS_ASSUME_NONNULL_END
