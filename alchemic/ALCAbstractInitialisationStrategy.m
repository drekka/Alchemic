//
//  ALCAbstractInitialisationStrategy.m
//  alchemic
//
//  Created by Derek Clarkson on 27/02/2015.
//  Copyright (c) 2015 Derek Clarkson. All rights reserved.
//

#import "ALCAbstractInitialisationStrategy.h"

#import "ALCLogger.h"
#import "ALCInitDetails.h"

#import <objc/runtime.h>


@implementation ALCAbstractInitialisationStrategy

static NSMutableArray *_initIMPStorage;

-(instancetype) init {
    self = [super init];
    if (self) {
        _initIMPStorage = [[NSMutableArray alloc] init];
    }
    return self;
}

-(void) wrapInitInClass:(Class) class withContext:(ALCContext *) context {
    
    // Get the new imp.
    SEL wrapperSelector = self.wrapperSelector;
    Method wrapperMethod = class_getInstanceMethod([self class], wrapperSelector);
    const char * wrapperTypeEncoding = method_getTypeEncoding(wrapperMethod);
    IMP wrapperIMP = class_getMethodImplementation([self class], wrapperSelector);
    
    // First attempt to add a new init.
    SEL initSelector = self.initSelector;
    if (class_addMethod(class, initSelector, wrapperIMP, wrapperTypeEncoding)) {
        logRuntime(@"Added %s::%s", class_getName(class), sel_getName(initSelector));
        [self storeInitFromClass:class
                    initSelector:initSelector
                         initIMP:NULL
                     withContext:context];
        return;
    }
    
    // There must already be an init, so now we replace it.
    logRuntime(@"Wrapping %s::%s", class_getName(class), sel_getName(initSelector));
    Method initMethod = class_getInstanceMethod(class, initSelector);
    IMP originalImp = method_setImplementation(initMethod, wrapperIMP);
    
    // And store the original init details.
    [self storeInitFromClass:class
                initSelector:initSelector
                     initIMP:originalImp
                 withContext:context];
    
}

-(void) storeInitFromClass:(Class) class
              initSelector:(SEL) initSelector
                   initIMP:(IMP) initIMP
               withContext:(ALCContext *) context {
    ALCInitDetails *initDetails = [[ALCInitDetails alloc] initWithOriginalClass:class
                                                                             initSelector:initSelector
                                                                                  initIMP:initIMP];
    [_initIMPStorage addObject:initDetails];
}

-(void) resetClasses {
    [_initIMPStorage enumerateObjectsUsingBlock:^(ALCInitDetails *replacedInitDetails, NSUInteger idx, BOOL *stop) {
        logRuntime(@"Resetting %s::%s", class_getName(replacedInitDetails.originalClass), sel_getName(replacedInitDetails.initSelector));
        Method initMethod = class_getInstanceMethod(replacedInitDetails.originalClass, replacedInitDetails.initSelector);
        method_setImplementation(initMethod, replacedInitDetails.initIMP);
    }];
}

+(ALCInitDetails *) initDetailsForClass:(Class) class initSelector:(SEL) initSelector {
    for (ALCInitDetails *replacedInitDetails in _initIMPStorage) {
        if (replacedInitDetails.originalClass == class && replacedInitDetails.initSelector == initSelector) {
            return replacedInitDetails;
        }
    }
    return nil;
}

-(BOOL) canWrapInitInClass:(Class) class {
    return NO;
}

-(SEL) wrapperSelector {
    return NULL;
}

-(SEL) initSelector {
    return NULL;
}

@end
