//
//  ALCModelClassProcessor.m
//  alchemic
//
//  Created by Derek Clarkson on 1/05/2015.
//  Copyright (c) 2015 Derek Clarkson. All rights reserved.
//

@import ObjectiveC;

#import "ALCModelClassProcessor.h"
#import "ALCInstance.h"
#import "ALCContext.h"
#import "ALCInternal.h"
#import "ALCLogger.h"

@implementation ALCModelClassProcessor

-(void) processClass:(Class)class withContext:(ALCContext *)context {
    ALCInstance *instance = [self executeAlchemicMethodsInClass:class];
    if (instance != nil) {
        [context addInstance:instance];
    }
}

static const size_t _prefixLength = strlen(_alchemic_toCharPointer(ALCHEMIC_PREFIX));

-(ALCInstance *) executeAlchemicMethodsInClass:(Class) class {
    
    // Get the class methods. We need to get the class of the class for them.
    unsigned int methodCount;
    Method *classMethods = class_copyMethodList(object_getClass(class), &methodCount);
    
    // Search the methods for registration methods.
    ALCInstance *instance = nil;
    for (size_t idx = 0; idx < methodCount; ++idx) {
        
        SEL sel = method_getName(classMethods[idx]);
        const char * methodName = sel_getName(sel);
        if (strncmp(methodName, _alchemic_toCharPointer(ALCHEMIC_PREFIX), _prefixLength) != 0) {
            continue;
        }
        
        if (instance == nil) {
            instance = [[ALCInstance alloc] initWithClass:class];
        }
        
        logRuntime(@"Executing %s::%s ...", class_getName(class), methodName);
        ((void (*)(id, SEL, ALCInstance *))objc_msgSend)(class, sel, instance); // Note cast because of XCode 6
        
    }
    
    free(classMethods);
    return instance;
}

@end
