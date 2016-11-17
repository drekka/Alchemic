//
//  ALCFactoryTypeReference.m
//  Alchemic
//
//  Created by Derek Clarkson on 31/01/2016.
//  Copyright © 2016 Derek Clarkson. All rights reserved.
//

#import <Alchemic/ALCObjectFactoryTypeReference.h>

#import <Alchemic/ALCInternalMacros.h>
#import <Alchemic/ALCException.h>

NS_ASSUME_NONNULL_BEGIN

@implementation ALCObjectFactoryTypeReference

-(ALCFactoryType) type {
    return ALCFactoryTypeReference;
}

-(nullable id) object {
    if (!self.isReady) {
        throwException(AlchemicReferenceObjectNotSetException, @"Factory %@ must have a value set before it can be accessed.", self.objectFactory);
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
