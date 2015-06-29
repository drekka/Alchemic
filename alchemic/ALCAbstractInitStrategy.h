//
//  ALCAbstractInitStrategy.h
//  alchemic
//
//  Created by Derek Clarkson on 27/02/2015.
//  Copyright (c) 2015 Derek Clarkson. All rights reserved.
//

@import Foundation;
@import ObjectiveC;
#import <StoryTeller/StoryTeller.h>

#import "ALCAbstractClass.h"
#import "ALCInitStrategy.h"
#import "ALCRuntime.h"

// Use this macro with the initLogic macro to safely wrap up the args. This allows us to passed multiple
// comma delimited arguments such as type declarations.
#define initLogicArg(...) , ## __VA_ARGS__

// Because the only difference between the code in various wrapper inits
// is the init argument types, this macro wraps this logic.
// This is because the code needs to be contained within the init method as this code is
// dynamically added to classes as needed.
// Note that the initLogicArg() macro must be used around the args.
/**
 @param _initSelectorName_ the name of the init selector.
 @param _initArgTypes_ zero or more data types as would be added to the objc_msgSend signature.
 @param _initArgArgs_ zero or more argument values as would be passed to the objc_msgSend call.
 */
#define initLogic(_initSelectorName_, _initArgTypes_, _initArgs_) \
Class selfClass = object_getClass(self); \
SEL initSel = @selector(_initSelectorName_); \
SEL relocatedInitSel = [ALCRuntime alchemicSelectorForSelector:initSel]; \
if ([self respondsToSelector:relocatedInitSel]) { \
self = ((id (*)(id, SEL _initArgTypes_))objc_msgSend)(self, relocatedInitSel _initArgs_); \
} else { \
struct objc_super superData = {self, class_getSuperclass(selfClass)}; \
self = ((id (*)(struct objc_super *, SEL _initArgTypes_))objc_msgSendSuper)(&superData, initSel _initArgs_); \
} \
log(selfClass, @"Triggering dependency injection from %s::%s", class_getName(selfClass), sel_getName(initSel)); \
[[Alchemic mainContext] injectDependencies:self]; \
return self

@interface ALCAbstractInitStrategy : NSObject<ALCInitStrategy, ALCAbstractClass>

@property (nonatomic, assign, readonly) SEL initSelector;
@property (nonatomic, assign, readonly) SEL replacementInitSelector;

@end
