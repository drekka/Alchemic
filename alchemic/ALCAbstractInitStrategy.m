//
//  ALCAbstractInitStrategy.m
//  alchemic
//
//  Created by Derek Clarkson on 27/02/2015.
//  Copyright (c) 2015 Derek Clarkson. All rights reserved.
//

#import "ALCAbstractInitStrategy.h"

#import "ALCLogger.h"
#import "ALCInstance.h"
#import "ALCInternal.h"
#import "ALCRuntime.h"
#import "ALCInternal.h"

@import ObjectiveC;

@implementation ALCAbstractInitStrategy {
    Class _forClass;
}

@synthesize initSelector;
@synthesize replacementInitSelector;

// Abstract
+(BOOL) canWrapInit:(ALCInstance *) instance {
    [self doesNotRecognizeSelector:@selector(canWrapInit:)];
    return NO;
}

-(instancetype) initWithInstance:(ALCInstance *)instance {
    self = [super init];
    if (self) {
        _forClass = instance.forClass;
        [self wrapInit];
    }
    return self;
}

-(void) wrapInit {
    
    // Check to see if the class has already been modified for this init.
    SEL initSel = self.initSelector;
    const char *initPropertyName = [ALCRuntime concat:_alchemic_toCharPointer(ALCHEMIC_PREFIX) to:sel_getName(initSel)];

    logRuntime(@"Replacing %s::%s with wrapper %2$s", class_getName(_forClass), sel_getName(initSel));
    NSNumber *initAdded = objc_getAssociatedObject(_forClass, initPropertyName);
    if ([initAdded boolValue]) {
        logRuntime(@"Init method already replaced.");
        return;
    }

    Class selfClass = object_getClass(self);
    SEL replacementInitSel = self.replacementInitSelector;

    // Get the new methods details.
    Method replacementMethod = class_getInstanceMethod(selfClass, replacementInitSel);
    const char * initTypeEncoding = method_getTypeEncoding(replacementMethod);
    IMP wrapperIMP = class_getMethodImplementation(selfClass, replacementInitSel);

    // Add or replace any existing IMP with a wrapper IMP.
    IMP originalInitIMP = class_replaceMethod(_forClass, initSel, wrapperIMP, initTypeEncoding);
    if (originalInitIMP != NULL) {
        // There was an original init method so save it so it can be found.
        SEL alchemicInitSel = [ALCRuntime alchemicSelectorForSelector:initSel];
        logRuntime(@"Storing original init as %s::%s", class_getName(selfClass), sel_getName(alchemicInitSel));
        class_addMethod(_forClass, alchemicInitSel, originalInitIMP, initTypeEncoding);
    }
 
    // Tag the class so we know it's been modified.
    objc_setAssociatedObject(_forClass, initPropertyName, @YES, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    
}

@end
