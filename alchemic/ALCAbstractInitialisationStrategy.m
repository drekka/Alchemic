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
    ALCOriginalInitInfo *initDetails = [[ALCOriginalInitInfo alloc] initWithOriginalClass:class
                                                                             initSelector:initSelector
                                                                                  initIMP:initIMP];
    [_initIMPStorage addObject:initDetails];
}

-(void) resetClasses {
    [_initIMPStorage enumerateObjectsUsingBlock:^(ALCOriginalInitInfo *replacedInitInfo, NSUInteger idx, BOOL *stop) {
        logRuntime(@"Resetting %s::%s", class_getName(replacedInitInfo.originalClass), sel_getName(replacedInitInfo.initSelector));
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
