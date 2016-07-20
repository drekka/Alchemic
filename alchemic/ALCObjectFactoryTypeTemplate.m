//
//  ALCFactoryTypeFactory.m
//  Alchemic
//
//  Created by Derek Clarkson on 31/01/2016.
//  Copyright © 2016 Derek Clarkson. All rights reserved.
//

#import <Alchemic/ALCObjectFactoryTypeTemplate.h>
#import <Alchemic/ALCInternalMacros.h>

NS_ASSUME_NONNULL_BEGIN

@implementation ALCObjectFactoryTypeTemplate

-(ALCFactoryType) type {
    return ALCFactoryTypeTemplate;
}

-(void) setWeak:(BOOL) weak {
    if (weak) {
        throwException(IllegalArgument, @"Templates cannot be set as weak references.");
    }
}

-(void) setNullable:(BOOL) nullable {
    if (nullable) {
        throwException(IllegalArgument, @"Templates cannot be set as nullable.");
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

