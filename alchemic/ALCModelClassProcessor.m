//
//  ALCModelClassProcessor.m
//  alchemic
//
//  Created by Derek Clarkson on 1/05/2015.
//  Copyright (c) 2015 Derek Clarkson. All rights reserved.
//

@import ObjectiveC;

#import "ALCModelClassProcessor.h"
#import "ALCResolvableObject.h"
#import "ALCContext.h"
#import "ALCInternal.h"
#import "ALCLogger.h"

@implementation ALCModelClassProcessor

static const size_t _prefixLength = strlen(_alchemic_toCharPointer(ALCHEMIC_PREFIX));

-(void) processClass:(Class)class withContext:(ALCContext *)context {
    
    // Get the class methods. We need to get the class of the class for them.
    unsigned int methodCount;
    Method *classMethods = class_copyMethodList(object_getClass(class), &methodCount);
    
    // Search the methods for registration methods.
    ALCResolvableObject *currentClassInstance = nil;
    for (size_t idx = 0; idx < methodCount; ++idx) {
        
        // If the method is not an alchemic one, then ignore it.
        SEL sel = method_getName(classMethods[idx]);
        const char * methodName = sel_getName(sel);
        if (strncmp(methodName, _alchemic_toCharPointer(ALCHEMIC_PREFIX), _prefixLength) != 0) {
            continue;
        }
        
        // If we are here then we have an alchemic method to process.
        if (currentClassInstance == nil) {
            currentClassInstance = [context.model addResolvableObjectForClass:class inContext:context];
        }
        
        logRuntime(@"Executing %s::%s ...", class_getName(class), methodName);
        // Note cast because of XCode 6
        // If this returns a new ALCInstance it is assumed to be a new model object and is added.
        ((void (*)(id, SEL, ALCResolvableObject *))objc_msgSend)(class, sel, currentClassInstance);
        
    }
    
    free(classMethods);
}

@end
