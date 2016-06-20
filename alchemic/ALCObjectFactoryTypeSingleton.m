//
//  ALCFactoryTypeSingleton.m
//  Alchemic
//
//  Created by Derek Clarkson on 30/01/2016.
//  Copyright © 2016 Derek Clarkson. All rights reserved.
//

#import <Alchemic/ALCObjectFactoryTypeSingleton.h>

NS_ASSUME_NONNULL_BEGIN

@implementation ALCObjectFactoryTypeSingleton

-(BOOL) ready {
    return YES;
}

-(NSString *)description {
    return @"Singleton";
}

@end

NS_ASSUME_NONNULL_END