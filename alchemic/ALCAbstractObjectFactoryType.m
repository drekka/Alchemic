//
//  ALCAbstractObjectFactoryType.m
//  Alchemic
//
//  Created by Derek Clarkson on 20/06/2016.
//  Copyright © 2016 Derek Clarkson. All rights reserved.
//

#import <Alchemic/ALCAbstractObjectFactoryType.h>
#import <Alchemic/ALCInternalMacros.h>

NS_ASSUME_NONNULL_BEGIN

@implementation ALCAbstractObjectFactoryType {
    __weak id _weakObjectRef;
    id _strongObjectRef;
}

@synthesize weak = _weak;
@synthesize nillable = _nillable;

#pragma mark - Override properties

-(ALCFactoryType) type {
    return ALCFactoryTypeSingleton;
}

-(void)setObject:(nullable id) object {
    
    if (!object && !_nillable) {
        throwException(AlchemicNilValueException, @"Cannot set a nil value.");
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

-(BOOL)isObjectPresent {
    return _weakObjectRef || _strongObjectRef;
}

-(NSString *) description {
    methodNotImplemented;
    return @"";
}

-(NSString *) descriptionWithType:(NSString *) type {
    return str(@"%@%@%@", self.nillable ? @"nillable " : @"", self.isWeak ? @"weak " : @"", type);
}


@end

NS_ASSUME_NONNULL_END
