//
//  ALCSimpleObjectFactory.m
//  alchemic
//
//  Created by Derek Clarkson on 23/02/2015.
//  Copyright (c) 2015 Derek Clarkson. All rights reserved.
//

#import "ALCSimpleObjectFactory.h"
#import "ALCLogger.h"
#import "ALCInstance.h"
#import "ALCRuntime.h"
#import "ALCContext.h"

@import ObjectiveC;


@implementation ALCSimpleObjectFactory {
    __weak ALCContext *_context;
}

-(instancetype) initWithContext:(ALCContext *) context {
    self = [super init];
    if (self) {
        _context = context;
    }
    return self;
}

-(id) createObjectFromInstance:(ALCInstance *) instance {
    
    logCreation(@"Creating instance using %s::init", class_getName(instance.forClass));
    id obj = [instance.forClass alloc];
    SEL initSel = @selector(init);
    
    // Because any known class will have an overridden init which does DI for when an object is created outside of Alchemic, we need to call the original code or super init.
    SEL originalInit = [ALCRuntime alchemicSelectorForSelector:@selector(init)];
    if (class_respondsToSelector(instance.forClass, originalInit)) {
        logRuntime(@"Calling original init method %s::%s", class_getName(instance.forClass), sel_getName(originalInit));
        return ((id (*)(id, SEL))objc_msgSend)(obj, originalInit);
    } else {
        struct objc_super superData = {obj, class_getSuperclass(instance.forClass)};
        logRuntime(@"Calling classes super init %s::%s", class_getName(superData.super_class), sel_getName(initSel));
        return ((id (*)(struct objc_super *, SEL))objc_msgSendSuper)(&superData, initSel);
    }
}

@end
