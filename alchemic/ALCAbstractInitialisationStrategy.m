//
//  ALCAbstractInitialisationStrategy.m
//  alchemic
//
//  Created by Derek Clarkson on 27/02/2015.
//  Copyright (c) 2015 Derek Clarkson. All rights reserved.
//

#import "ALCAbstractInitialisationStrategy.h"

#import "ALCLogger.h"
#import "ALCOriginalInitInfo.h"

#import <objc/runtime.h>


@implementation ALCAbstractInitialisationStrategy

static NSArray *_initIMPStorage;

-(instancetype) init {
    self = [super init];
    if (self) {
        logClassProcessing(@"Initialising init IMP storage area for %s", class_getName([self class]));
        _initIMPStorage = [[NSArray alloc] init];
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
        logClassProcessing(@"Added new init to %s", class_getName(class));
        [self storeInitFromClass:class
                    initSelector:initSelector
                         initIMP:NULL
                     withContext:context];
        return;
    }
    
    // There must already be an init, so now we replace it.
    logClassProcessing(@"Replacing init method %s::%s", class_getName(class), sel_getName(initSelector));
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
    ALCOriginalInitInfo *initDetails = [[ALCOriginalInitInfo alloc] initWithOriginalClass:class
                                                                             initSelector:initSelector
                                                                                  initIMP:initIMP
                                                                              withContext:context];
    _initIMPStorage = [_initIMPStorage arrayByAddingObject:initDetails];
}

-(void) resetClasses {
    [_initIMPStorage enumerateObjectsUsingBlock:^(ALCOriginalInitInfo *replacedInitInfo, NSUInteger idx, BOOL *stop) {
        logClassProcessing(@"Resetting init method %s::%s", class_getName(replacedInitInfo.originalClass), sel_getName(replacedInitInfo.initSelector));
        Method initMethod = class_getInstanceMethod(replacedInitInfo.originalClass, replacedInitInfo.initSelector);
        method_setImplementation(initMethod, replacedInitInfo.initIMP);
    }];
}

+(ALCOriginalInitInfo *) initInfoForClass:(Class) class initSelector:(SEL) initSelector {
    for (ALCOriginalInitInfo *replaceInfo in _initIMPStorage) {
        if (replaceInfo.originalClass == class && replaceInfo.initSelector == initSelector) {
            return replaceInfo;
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
