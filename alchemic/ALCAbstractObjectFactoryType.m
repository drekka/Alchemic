//
//  ALCAbstractObjectFactoryType.m
//  Alchemic
//
//  Created by Derek Clarkson on 20/06/2016.
//  Copyright © 2016 Derek Clarkson. All rights reserved.
//

#import "ALCAbstractObjectFactoryType.h"
#import "ALCInternalMacros.h"

NS_ASSUME_NONNULL_BEGIN

@implementation ALCAbstractObjectFactoryType {
    __weak id _weakObjectRef;
    id _strongObjectRef;
}

@synthesize weak = _weak;
@synthesize nullable = _nullable;

#pragma mark - Override properties

-(ALCFactoryType) type {
    return ALCFactoryTypeSingleton;
}

-(void)setObject:(nullable id) object {
    if (!object && !_nullable) {
        throwException(NilValue, @"Cannot set a nil value.");
    }
    if (_weak) {
        _weakObjectRef = object;
    } else {
        _strongObjectRef = object;
    }
}

-(nullable id) object {
    return _weak ? _weakObjectRef : _strongObjectRef;
}

-(BOOL) isReady {
    methodReturningBooleanNotImplemented;
}

-(NSString *) description {
    methodNotImplemented;
    return @"";
}

-(NSString *) descriptionWithType:(NSString *) type {
    return str(@"%@%@%@", self.nullable ? @"Nullable " : @"", self.isWeak ? @"Weak " : @"", type);
}


@end

NS_ASSUME_NONNULL_END
