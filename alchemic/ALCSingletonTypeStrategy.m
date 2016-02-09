//
//  ALCFactoryTypeSingleton.m
//  Alchemic
//
//  Created by Derek Clarkson on 30/01/2016.
//  Copyright © 2016 Derek Clarkson. All rights reserved.
//

#import "ALCSingletonTypeStrategy.h"

NS_ASSUME_NONNULL_BEGIN

@implementation ALCSingletonTypeStrategy

@synthesize object = _object;

-(bool) resolved {
    return YES;
}

@end

NS_ASSUME_NONNULL_END