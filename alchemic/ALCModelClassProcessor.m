//
//  ALCModelClassProcessor.m
//  alchemic
//
//  Created by Derek Clarkson on 1/05/2015.
//  Copyright (c) 2015 Derek Clarkson. All rights reserved.
//

@import ObjectiveC;
#import <StoryTeller/StoryTeller.h>
#import <Alchemic/ALCInternal.h>
#import <Alchemic/ALCContext.h>

#import "ALCModelClassProcessor.h"
#import "ALCClassBuilder.h"
#import "ALCContext+Internal.h"

@implementation ALCModelClassProcessor

-(void) processClass:(Class)class withContext:(ALCContext *)context {
    
    // Get the class methods. We need to get the class of the class for them.
    unsigned int methodCount;
    Method *classMethods = class_copyMethodList(object_getClass(class), &methodCount);
    
    // Search the methods for registration methods.
    ALCClassBuilder *currentClassBuilder = nil;
    NSString *alchemicMethodPrefix = _alchemic_toNSString(ALCHEMIC_PREFIX);
    for (size_t idx = 0; idx < methodCount; ++idx) {
        
        // If the method is not an alchemic one, then ignore it.
        SEL sel = method_getName(classMethods[idx]);
        if (![NSStringFromSelector(sel) hasPrefix:alchemicMethodPrefix]) {
            continue;
        }
        
        // If we are here then we have an alchemic method to process, so create a class builder for for the class.
        if (currentClassBuilder == nil) {
            currentClassBuilder = [[ALCClassBuilder alloc] initWithContext:context
                                                                 valueClass:class
                                                                       name:NSStringFromClass(class)];
            [context addBuilderToModel:currentClassBuilder];
        }

        // Call the method, passing it the current class builder.
        STLog(class, @"Executing %s::%s ...", class_getName(class), sel_getName(sel));
        ((void (*)(id, SEL, ALCClassBuilder *))objc_msgSend)(class, sel, currentClassBuilder);
        
    }
    
    free(classMethods);
}

@end
