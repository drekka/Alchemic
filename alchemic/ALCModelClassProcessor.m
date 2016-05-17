//
//  ALCModelClassProcessor.m
//  Alchemic
//
//  Created by Derek Clarkson on 17/05/2016.
//  Copyright © 2016 Derek Clarkson. All rights reserved.
//

#import <StoryTeller/StoryTeller.h>

#import "ALCModelClassProcessor.h"

#import "ALCMacros.h"
#import "ALCInternalMacros.h"
#import "ALCContext.h"

@implementation ALCModelClassProcessor

-(BOOL) canProcessClass:(Class) aClass {
    return YES;
}

-(NSSet<NSBundle *> *) processClass:(Class) aClass
                        withContext:(id<ALCContext>) context {
    ALCClassObjectFactory *factory;
    [self context:context executeAlchemicMethod:aClass classFactory:&factory];
    [self context:context executeAlchemicRegistrationMethods:aClass classFactory:&factory];
    return nil;
}

-(void) context:(id<ALCContext>) context executeAlchemicMethod:(Class) inClass classFactory:(ALCClassObjectFactory **) factory {
    
    AcIgnoreSelectorWarnings(
                             SEL alchemicFunctionSelector = @selector(alchemic:);
                             )
    if (![inClass respondsToSelector:alchemicFunctionSelector]) {
        return;
    }
    
    STLog(inClass, @"Class %@ has alchemic() method, executing", NSStringFromClass(inClass));
    if (!*factory) {
        *factory = [context registerObjectFactoryForClass:inClass];
    }
    
    // Call the function.
    ((void (*)(id, SEL, ALCClassObjectFactory *))objc_msgSend)(inClass, alchemicFunctionSelector, *factory);
}

-(void) context:(id<ALCContext>) context executeAlchemicRegistrationMethods:(Class) inClass classFactory:(ALCClassObjectFactory **) factory {
    
    // Get the class methods. We need to get the class of the class for them.
    unsigned int methodCount;
    Method *classMethods = class_copyMethodList(object_getClass(inClass), &methodCount);
    
    // Search the methods for alchemic methods. Their presence triggers registrations.
    for (size_t idx = 0; idx < methodCount; idx++) {
        
        // If the method is not an alchemic one, then ignore it.
        SEL nextSelector = method_getName(classMethods[idx]);
        if (![NSStringFromSelector(nextSelector) hasPrefix:alc_toNSString(ALCHEMIC_PREFIX)]) {
            continue;
        }
        
        // If we are here then we have an alchemic method to process, so create a class builder for for the class.
        STLog(inClass, @"Class %@ has alchemic methods", NSStringFromClass(inClass));
        if (!*factory) {
            *factory = [context registerObjectFactoryForClass:inClass];
        }
        
        // Call the method, passing it the current class builder.
        ((void (*)(id, SEL, ALCClassObjectFactory *))objc_msgSend)(inClass, nextSelector, *factory);
        
    }
    
    free(classMethods);
}

@end
