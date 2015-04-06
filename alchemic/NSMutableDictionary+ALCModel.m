//
//  NSDictionary+ALCModel.m
//  alchemic
//
//  Created by Derek Clarkson on 23/03/2015.
//  Copyright (c) 2015 Derek Clarkson. All rights reserved.
//

#import "NSMutableDictionary+ALCModel.h"

@import Foundation;
#import <objc/runtime.h>

#import "ALClogger.h"

#import "ALCRuntime.h"
#import "ALCDependencyResolver.h"

static const char *_nameProperty = "_alchemic_name";

@implementation NSMutableDictionary (ALCModel)

-(ALCInstance *) objectDescriptionForClass:(Class) class name:(NSString *) name {
    
    // Find the final name we are going to store under.
    NSString *nameFromClass = objc_getAssociatedObject(class, _nameProperty);
    NSString *className = NSStringFromClass(class);
    NSString *finalName = name == nil ? (nameFromClass == nil ? className : nameFromClass) : name;
    
    // if the name and class name are the same, either return an instance or create one.
    if ([finalName isEqualToString:className]) {
        ALCInstance *instance = self[className];
        if (instance == nil) {
            instance = [self createObjectDescriptionForClass:class name:className];
        }
        return instance;
    }
    
    // Class name and name are different, now check for an instance under the class name.
    ALCInstance *instance = self[className];
    if (instance == nil) {
        // Nothing under the class name so check the final name.
        instance = self[finalName];
        if (instance == nil) {
            instance = [self createObjectDescriptionForClass:class name:finalName];
        }
        return instance;
        
    }
    
    // There is an instance under the class name the move it.
    self[finalName] = instance;
    self[className] = nil;
    
    // Update the name used to store the class in the class so that other alchemic methods can find it.
    objc_setAssociatedObject(class, _nameProperty, finalName, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    
    return instance;
}

-(ALCInstance *) createObjectDescriptionForClass:(Class) class name:(NSString *) name {
    
    NSAssert(self[name] == nil, @"Cannot create an instance when one already exists with name %@", name);
    
    logRegistration(@"Creating info for '%2$s' (%1$@)", name, class_getName(class));
    [ALCRuntime decorateClass:class];
    ALCInstance *description = [[ALCInstance alloc] initWithClass:class];
    
    // Store the name used to store the class in the class so that other alchemic methods can find it.
    objc_setAssociatedObject(class, _nameProperty, name, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    
    self[name] = description;
    return description;
}

@end
