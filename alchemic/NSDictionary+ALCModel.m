//
//  NSDictionary+ALCModel.m
//  alchemic
//
//  Created by Derek Clarkson on 23/03/2015.
//  Copyright (c) 2015 Derek Clarkson. All rights reserved.
//

#import "NSDictionary+ALCModel.h"

@import Foundation;
#import "ALCObjectDescription.h"
#import "ALCRuntimeFunctions.h"
#import "ALCDependencyResolver.h"
#import <objc/runtime.h>
#import "ALClogger.h"

@implementation NSDictionary (ALCModel)

-(NSDictionary *) objectDescriptionsForClass:(Class) aClass
                                   protocols:(NSArray *) protocols
                                   qualifier:(NSString *) qualifier
                              usingResolvers:(NSArray *) resolvers {
    
    NSDictionary *candidates = nil;
    for (id<ALCDependencyResolver> resolver in resolvers) {
        logDependencyResolving(@"Asking %s to resolve '%@' %s<%@>", class_getName([resolver class]), qualifier, class_getName(aClass), [protocols componentsJoinedByString:@","]);
        candidates = [resolver resolveDependencyWithClass:aClass protocols:protocols name:qualifier];
        if (candidates != nil) {
            break;
        }
    }
    return candidates;
}


-(NSDictionary *) objectDescriptionsForClass:(Class) class {
    NSMutableDictionary *results = [[NSMutableDictionary alloc] init];
    [self enumerateKeysAndObjectsUsingBlock:^(NSString *name, ALCObjectDescription *description, BOOL *stop) {
        if (class_decendsFromClass(description.forClass, class)) {
            results[name] = description;
        }
    }];
    return results;
}

-(NSDictionary *) objectDescriptionsWithProtocol:(Protocol *) protocol {
    NSMutableDictionary *results = [[NSMutableDictionary alloc] init];
    [self enumerateKeysAndObjectsUsingBlock:^(NSString *name, ALCObjectDescription *description, BOOL *stop) {
        if (class_conformsToProtocol(description.forClass, protocol)) {
            results[name] = description;
        }
    }];
    return results;
}

@end
