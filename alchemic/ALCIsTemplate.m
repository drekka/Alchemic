//
//  IsSngleton.m
//  alchemic
//
//  Created by Derek Clarkson on 7/06/2015.
//  Copyright (c) 2015 Derek Clarkson. All rights reserved.
//

#import <Alchemic/ALCIsTemplate.h>

@implementation ALCIsTemplate

+ (instancetype) templateMacro  {
    static id singletonInstance = nil;
    if (!singletonInstance) {
        static dispatch_once_t onceToken;
        dispatch_once(&onceToken, ^{
            singletonInstance = [[super allocWithZone:NULL] init];
        });
    }
    return singletonInstance;
}

+ (id)allocWithZone:(NSZone *) zone {
    return [self templateMacro];
}

- (id)copyWithZone:(NSZone *) zone {
    return self;
}

@end
