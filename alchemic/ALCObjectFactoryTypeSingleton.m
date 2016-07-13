//
//  ALCFactoryTypeSingleton.m
//  Alchemic
//
//  Created by Derek Clarkson on 30/01/2016.
//  Copyright © 2016 Derek Clarkson. All rights reserved.
//

#import <Alchemic/ALCObjectFactoryTypeSingleton.h>
#import <Alchemic/ALCInternalMacros.h>
#import <Alchemic/ALCStringMacros.h>

NS_ASSUME_NONNULL_BEGIN

@implementation ALCObjectFactoryTypeSingleton

-(void) setNullable:(BOOL) nullable {
    if (nullable) {
        throwException(IllegalArgument, @"Singletons cannot be set as nullable.");
    }
}

-(BOOL) isReady {
    return YES;
}

-(NSString *)description {
    return [self descriptionWithType:@"Singleton"];
}

@end

NS_ASSUME_NONNULL_END
