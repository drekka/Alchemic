//
//  IsSngleton.m
//  alchemic
//
//  Created by Derek Clarkson on 7/06/2015.
//  Copyright (c) 2015 Derek Clarkson. All rights reserved.
//

#import "ALCIsFactory.h"

@implementation ALCIsFactory

+ (instancetype) factoryMacro  {
    static id singletonInstance = nil;
    if (!singletonInstance) {
        static dispatch_once_t onceToken;
        dispatch_once(&onceToken, ^{
            singletonInstance = [[super allocWithZone:NULL] init];
        });
    }
    return singletonInstance;
}

+ (id)allocWithZone:(NSZone *)zone {
    return [self factoryMacro];
}

- (id)copyWithZone:(NSZone *)zone {
    return self;
}

@end
