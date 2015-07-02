//
//  ALCAbstractInitStrategy.m
//  alchemic
//
//  Created by Derek Clarkson on 27/02/2015.
//  Copyright (c) 2015 Derek Clarkson. All rights reserved.
//

@import ObjectiveC;
#import <StoryTeller/StoryTeller.h>

#import "ALCAbstractInitStrategy.h"
#import "ALCType.h"
#import "ALCClassBuilder.h"
#import <Alchemic/ALCInternal.h>

@implementation ALCAbstractInitStrategy {
    Class _forClass;
}

@synthesize initSelector;
@synthesize replacementInitSelector;

// Abstract
+(BOOL) canWrapInit:(ALCClassBuilder *) classBuilder {
    [self doesNotRecognizeSelector:_cmd];
    return NO;
}

-(instancetype) initWithClassBuilder:(ALCClassBuilder *)classBuilder {
    self = [super init];
    if (self) {
        _forClass = classBuilder.valueType.typeClass;
        [self wrapInit];
    }
    return self;
}

-(void) wrapInit {
    
    // Check to see if the class has already been modified for this init.
    SEL initSel = self.initSelector;
    const char *initPropertyName = [ALCRuntime concat:_alchemic_toCharPointer(ALCHEMIC_PREFIX) to:sel_getName(initSel)];

    STLog(_forClass, @"Replacing %s::%s with wrapper %2$s", class_getName(_forClass), sel_getName(initSel));
    NSNumber *initAdded = objc_getAssociatedObject(_forClass, initPropertyName);
    if ([initAdded boolValue]) {
        STLog(_forClass, @"Init method already replaced.");
        return;
    }

    Class selfClass = [self class];
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
        STLog(_forClass, @"Storing original init as %s::%s", class_getName(selfClass), sel_getName(alchemicInitSel));
        class_addMethod(_forClass, alchemicInitSel, originalInitIMP, initTypeEncoding);
    }
 
    // Tag the class so we know it's been modified.
    objc_setAssociatedObject(_forClass, initPropertyName, @YES, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    
}

@end
