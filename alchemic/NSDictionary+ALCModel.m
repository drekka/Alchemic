//
//  NSDictionary+ALCModel.m
//  alchemic
//
//  Created by Derek Clarkson on 23/03/2015.
//  Copyright (c) 2015 Derek Clarkson. All rights reserved.
//

#import "NSDictionary+ALCModel.h"

@import Foundation;
#import "ALCClassInfo.h"
#import "ALCRuntimeFunctions.h"
#import <objc/runtime.h>

@implementation NSDictionary (ALCModel)

-(NSDictionary *) infoObjectsOfClass:(Class) class {
    NSMutableDictionary *results = [[NSMutableDictionary alloc] init];
    [self enumerateKeysAndObjectsUsingBlock:^(NSString *name, ALCClassInfo *info, BOOL *stop) {
        if (class_decendsFromClass(info.forClass, class)) {
            results[name] = info;
        }
    }];
    return results;
}

-(NSDictionary *) infoObjectsWithProtocol:(Protocol *) protocol {
    NSMutableDictionary *results = [[NSMutableDictionary alloc] init];
    [self enumerateKeysAndObjectsUsingBlock:^(NSString *name, ALCClassInfo *info, BOOL *stop) {
        if (class_conformsToProtocol(info.forClass, protocol)) {
            results[name] = info;
        }
    }];
    return results;
}

@end
