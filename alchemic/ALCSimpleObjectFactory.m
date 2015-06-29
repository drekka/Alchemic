//
//  ALCSimpleObjectFactory.m
//  alchemic
//
//  Created by Derek Clarkson on 23/02/2015.
//  Copyright (c) 2015 Derek Clarkson. All rights reserved.
//

#import "ALCSimpleObjectFactory.h"
#import <StoryTeller/StoryTeller.h>
#import "ALCClassBuilder.h"
#import "ALCRuntime.h"
#import "ALCType.h"

@import ObjectiveC;

@implementation ALCSimpleObjectFactory

-(id) createObjectFromBuilder:(ALCClassBuilder *) builder {
    
    Class objClass = builder.valueType.typeClass;
    id obj = [objClass alloc];
    SEL initSel = @selector(init);
    
    // Because any known class will have an overridden init which does DI for when an object is created outside of Alchemic, we need to call the original code or super init.
    SEL originalInit = [ALCRuntime alchemicSelectorForSelector:@selector(init)];
    if (class_respondsToSelector(objClass, originalInit)) {
    
        log(objClass, @"   using original %s::%s", class_getName(objClass), sel_getName(originalInit));
        return ((id (*)(id, SEL))objc_msgSend)(obj, originalInit);

    } else {
        
        struct objc_super superData = {obj, class_getSuperclass(objClass)};
        log(objClass, @"   using super %s::%s", class_getName(superData.super_class), sel_getName(initSel));
        return ((id (*)(struct objc_super *, SEL))objc_msgSendSuper)(&superData, initSel);
    }
}

@end
