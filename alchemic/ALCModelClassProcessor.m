//
//  ALCModelClassProcessor.m
//  Alchemic
//
//  Created by Derek Clarkson on 17/05/2016.
//  Copyright © 2016 Derek Clarkson. All rights reserved.
//

#import <StoryTeller/StoryTeller.h>

#import <Alchemic/ALCModelClassProcessor.h>

#import <Alchemic/ALCMacros.h>
#import <Alchemic/ALCInternalMacros.h>
#import <Alchemic/ALCContext.h>

@implementation ALCModelClassProcessor

-(BOOL) canProcessClass:(Class) aClass {
    return YES;
}

-(NSSet<NSBundle *> *) processClass:(Class) aClass
                        withContext:(id<ALCContext>) context {
    
    ALCClassObjectFactory *factory;
    
    AcIgnoreSelectorWarnings(
                             SEL alchemicFunctionSelector = @selector(alchemic:);
                             )
    
    // Get the class methods. Using class methods means we are likely to have to scan fewer methods than if we scanning instance methods. Also means we don't have to instantiate the class to do registrations. Note: we need to get the class of the class to list them.
    unsigned int methodCount;
    Method *classMethods = class_copyMethodList(object_getClass(aClass), &methodCount);
    
    // Search the methods for alchemic methods. Their presence triggers registrations.
    for (size_t idx = 0; idx < methodCount; idx++) {
        
        // If the method is not an alchemic one, then ignore it.
        SEL nextSelector = method_getName(classMethods[idx]);
        if (nextSelector == alchemicFunctionSelector
            || [NSStringFromSelector(nextSelector) hasPrefix:alc_toNSString(ALCHEMIC_PREFIX)]) {
            
            // If we are here then we have an alchemic method to process, so create an object factory.
            if (!factory) {
                STLog(aClass, @"Class %@ has alchemic methods, creating factory", NSStringFromClass(aClass));
                factory = [context registerObjectFactoryForClass:aClass];
            }
            
            // Call the method, passing it the current class builder.
            ((void (*)(id, SEL, ALCClassObjectFactory *))objc_msgSend)(aClass, nextSelector, factory);
        }
        
    }
    
    free(classMethods);
    return nil;
}


@end
