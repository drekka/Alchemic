//
//  ALCFactoryTypeReference.m
//  Alchemic
//
//  Created by Derek Clarkson on 31/01/2016.
//  Copyright © 2016 Derek Clarkson. All rights reserved.
//

#import <Alchemic/ALCObjectFactoryTypeReference.h>
#import <Alchemic/ALCMacros.h>
#import <Alchemic/ALCInternalMacros.h>
#import <Alchemic/ALCException.h>

NS_ASSUME_NONNULL_BEGIN

@implementation ALCObjectFactoryTypeReference

-(ALCFactoryType) type {
    return ALCFactoryTypeReference;
}

-(BOOL) isReady {
    return YES;
}

-(NSString *)description {
    return self.isWeak ? @"Weak Reference" : @"Reference";
}

@end

NS_ASSUME_NONNULL_END
