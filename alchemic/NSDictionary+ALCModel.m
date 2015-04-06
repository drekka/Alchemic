//
//  NSDictionary+ALCModel.m
//  alchemic
//
//  Created by Derek Clarkson on 6/04/2015.
//  Copyright (c) 2015 Derek Clarkson. All rights reserved.
//

#import "NSDictionary+ALCModel.h"

#import "ALCInstance.h"
#import "ALCRuntime.h"

@implementation NSDictionary (ALCModel)

#pragma mark - Searching the model

-(NSDictionary *) objectDescriptionsWithClass:(Class) class {
    NSMutableDictionary *results = [[NSMutableDictionary alloc] init];
    [self enumerateKeysAndObjectsUsingBlock:^(NSString *name, ALCInstance *description, BOOL *stop) {
        if ([ALCRuntime class:description.forClass extends:class]) {
            results[name] = description;
        }
    }];
    return results;
}

-(NSDictionary *) objectDescriptionsWithProtocol:(Protocol *) protocol {
    NSMutableDictionary *results = [[NSMutableDictionary alloc] init];
    [self enumerateKeysAndObjectsUsingBlock:^(NSString *name, ALCInstance *description, BOOL *stop) {
        if (class_conformsToProtocol(description.forClass, protocol)) {
            results[name] = description;
        }
    }];
    return results;
}

@end
