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

-(BOOL) isReady {
    return YES;
}

-(NSString *)description {
    return [self descriptionWithType:@"Singleton"];
}

@end

NS_ASSUME_NONNULL_END
