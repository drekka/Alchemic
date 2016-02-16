//
//  ALCFactoryTypeSingleton.m
//  Alchemic
//
//  Created by Derek Clarkson on 30/01/2016.
//  Copyright © 2016 Derek Clarkson. All rights reserved.
//

#import "ALCObjectFactoryTypeSingleton.h"

NS_ASSUME_NONNULL_BEGIN

@implementation ALCObjectFactoryTypeSingleton

@synthesize object = _object;

-(bool) ready {
    return YES;
}

@end

NS_ASSUME_NONNULL_END