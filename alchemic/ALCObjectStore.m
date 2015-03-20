//
//  ALCObjectStore.m
//  alchemic
//
//  Created by Derek Clarkson on 9/03/2015.
//  Copyright (c) 2015 Derek Clarkson. All rights reserved.
//

#import "ALCObjectStore.h"

#import <objc/runtime.h>

#import "ALCLogger.h"
#import "ALCObjectProxy.h"
#import "ALCClassInfo.h"
#import "ALCRuntime.h"
#import "ALCRuntimeFunctions.h"

@implementation ALCObjectStore {
    NSMutableArray *_objects;
    NSMutableDictionary *_objectsByName;
    __weak ALCContext *_context;
}

#pragma mark - Lifecycle

-(instancetype) initWithContext:(__weak ALCContext *) context {
    self = [super init];
    if (self) {
        _context = context;
        _objects = [[NSMutableArray alloc] init];
    }
    return self;
}

-(void) instantiateSingletons {
    [_objects enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        if ([obj class] == [ALCObjectProxy class]) {
            ALCObjectProxy *proxy = (ALCObjectProxy *) obj;
            if (proxy.classInfo.isSingleton) {
                logCreation(@"--- Instantiating %s singleton", class_getName(proxy.classInfo.forClass));
                [proxy instantiate];
                logCreation(@"--- %s singleton created", class_getName(proxy.classInfo.forClass));
            }
        }
    }];
}

#pragma mark - Adding objects

-(void) addLazyInstantionForClass:(ALCClassInfo *) classInfo {
    [self addLazyInstantionForClass:classInfo withName:NSStringFromClass([classInfo.forClass class])];
}

-(void) addLazyInstantionForClass:(ALCClassInfo *) classInfo withName:(NSString *) name {
    ALCObjectProxy *proxy = [[ALCObjectProxy alloc] initWithFutureObjectInfo:classInfo context:_context];
    [self addObject:proxy withName:name];
}

-(void) addObject:(id) object {
    [self addObject:object withName:NSStringFromClass([object class])];
}

-(void) addObject:(id) object withName:(NSString *)name {
    
    [_objects addObject:object];
    
    // Find the name list for the object.
    NSMutableArray *objectList = _objectsByName[name];
    if (objectList == nil) {
        objectList = [[NSMutableArray alloc] init];
        _objectsByName[name] = objectList;
    }
    [objectList addObject:object];
}

#pragma mark - Searching for objects

-(NSArray *) objectsOfClass:(Class) aClass {
    
    NSMutableArray *results = [[NSMutableArray alloc] init];
    Class proxyClass = [ALCObjectProxy class];
    
    for (id object in _objects) {
        
        // Work out the class of the object we are dealing with.
        Class objClass = [object class];
        if (objClass == proxyClass) {
            objClass = ((ALCObjectProxy *)object).classInfo.forClass;
        }

        if (class_decendsFromClass(objClass, aClass)) {
            [results addObject:object];
        }
        
    };
    
    logObjectResolving(@"Returning %i objects of class %s", [results count], class_getName(aClass));
    return [results count] == 0 ? nil : results;
}

-(NSArray *) objectsWithName:(NSString *) name {
    NSArray *results = _objectsByName[name];
    logObjectResolving(@"Returning %i objects for name %@", [results count], name);
    return results;
}


-(NSArray *) objectsWithProtocol:(Protocol *) protocol {
    NSArray *results = [ALCRuntime filterObjects:_objects forProtocols:@[protocol]];
    logObjectResolving(@"Returning %i objects implementing protocol %s", [results count], protocol_getName(protocol));
    return results;
}

@end
