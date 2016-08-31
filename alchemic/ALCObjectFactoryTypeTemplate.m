//
//  ALCFactoryTypeFactory.m
//  Alchemic
//
//  Created by Derek Clarkson on 31/01/2016.
//  Copyright © 2016 Derek Clarkson. All rights reserved.
//

#import "ALCObjectFactoryTypeTemplate.h"
#import "ALCInternalMacros.h"

NS_ASSUME_NONNULL_BEGIN

@implementation ALCObjectFactoryTypeTemplate

-(ALCFactoryType) type {
    return ALCFactoryTypeTemplate;
}

-(void) setWeak:(BOOL) weak {
    if (weak) {
        throwException(AlchemicIllegalArgumentException, @"Templates cannot be set as weak references.");
    }
}

-(void) setNillable:(BOOL) nillable {
    if (nillable) {
        throwException(AlchemicIllegalArgumentException, @"Templates cannot be set as nillable.");
    }
}

-(BOOL) isReady {
    return YES;
}

-(BOOL)isObjectPresent {
    return NO;
}

-(void) setObject:(nullable id) value {
    // Templates just ignore any value being set.
}

-(NSString *)description {
    return [self descriptionWithType:@"Template"];
}

@end

NS_ASSUME_NONNULL_END

