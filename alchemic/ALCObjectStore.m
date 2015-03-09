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

@implementation ALCObjectStore {
    NSMutableDictionary *_byClass;
    NSMutableDictionary *_byProtocol;
}

-(instancetype) init {
    self = [super init];
    if (self) {
        _byClass = [[NSMutableDictionary alloc] init];
        _byProtocol = [[NSMutableDictionary alloc] init];
    }
    return self;
}

-(void) addObject:(id) object {

    Class objClass = [object class];
    
    // Add to the list of objects for the class.
    NSArray *objs = _byClass[objClass];
    if (objs == nil) {
        objs = @[];
        _byClass[(id<NSCopying>)objClass] = objs;
    }
    logObjectResolving(@"Object added to store with class %s", class_getName(objClass));
    _byClass[(id<NSCopying>)objClass] = [objs arrayByAddingObject:object];
    
    // Find the protocols for the object.
    unsigned int nbrProtocols;
    __unsafe_unretained Protocol **protocols = class_copyProtocolList(objClass, &nbrProtocols);
    Protocol *protocol;
    for (size_t idx = 0; idx < nbrProtocols; ++idx) {
        protocol = protocols[idx];
        logObjectResolving(@"Object added with protocol %s", protocol_getName(protocol));

        // Add the protocol.
        NSString *protocolName = NSStringFromProtocol(protocol);
        NSArray *objByProtocol = _byProtocol[protocolName];
        if (objByProtocol == nil) {
            objByProtocol = @[];
            _byProtocol[protocolName] = objByProtocol;
        }
        _byProtocol[protocolName] = [objByProtocol arrayByAddingObject:object];
        
    }
    
}

-(NSArray *) objectsOfClass:(Class) aClass {
    return nil;
}

-(NSArray *) objectsWithProtocol:(Protocol *) protocol {
    return nil;
}

-(NSArray *) objectsWithSelector:(SEL) selector {
    return nil;
}

+(NSArray *) objectsInArray:(NSArray *) array withProtocol:(Protocol *) protocol {
    return nil;
}

+(NSArray *) objectsInArray:(NSArray *) array withSelector:(SEL) selector {
    return nil;
}

@end
