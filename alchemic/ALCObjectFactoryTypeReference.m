//
//  ALCFactoryTypeReference.m
//  Alchemic
//
//  Created by Derek Clarkson on 31/01/2016.
//  Copyright © 2016 Derek Clarkson. All rights reserved.
//

#import "ALCObjectFactoryTypeReference.h"
#import "ALCMacros.h"
#import "ALCInternalMacros.h"
#import "ALCStringMacros.h"
#import "ALCException.h"

NS_ASSUME_NONNULL_BEGIN

@implementation ALCObjectFactoryTypeReference

-(ALCFactoryType) type {
    return ALCFactoryTypeReference;
}

-(nullable id) object {
    if (!self.isReady) {
        throwException(ReferenceObjectNotSet, @"%@ is a reference factory which has not had a value set.", self);
    }
    return super.object;
}

-(BOOL) isReady {
    return self.nillable || super.object != nil;
}

-(NSString *)description {
    return [self descriptionWithType:@"Reference"];
}

@end

NS_ASSUME_NONNULL_END
