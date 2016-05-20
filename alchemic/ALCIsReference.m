//
//  ALCIsExternal.m
//  alchemic
//
//  Created by Derek Clarkson on 25/08/2015.
//  Copyright © 2015 Derek Clarkson. All rights reserved.
//

#import <Alchemic/ALCIsReference.h>

@implementation ALCIsReference

+ (instancetype) referenceMacro {
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
    return [self referenceMacro];
}

- (id)copyWithZone:(NSZone *)zone {
    return self;
}

@end
