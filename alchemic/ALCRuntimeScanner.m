//
//  ALCRuntimeScanner.m
//  Alchemic
//
//  Created by Derek Clarkson on 8/07/2015.
//  Copyright © 2015 Derek Clarkson. All rights reserved.
//

@import ObjectiveC;
#import <StoryTeller/StoryTeller.h>

#import "ALCRuntimeScanner.h"
#import "ALCClassBuilder.h"
#import "ALCInternalMacros.h"
#import "ALCDependencyPostProcessor.h"
#import "ALCResourceLocator.h"
#import "ALCContext.h"

@implementation ALCRuntimeScanner

-(nonnull instancetype) initWithSelector:(ClassSelector _Nonnull) selector
                               processor:(ClassProcessor _Nonnull) processor {
    self = [super init];
    if (self) {
        _selector = selector;
        _processor = processor;
    }
    return self;
}

+(nonnull instancetype) modelScanner {
    return [[ALCRuntimeScanner alloc]
            initWithSelector:^BOOL(Class  _Nonnull __unsafe_unretained aClass) {
                return YES;
            }
            processor:^(ALCContext * _Nonnull context, Class  _Nonnull __unsafe_unretained aClass) {

                // Get the class methods. We need to get the class of the class for them.
                unsigned int methodCount;
                Method *classMethods = class_copyMethodList(object_getClass(aClass), &methodCount);

                // Search the methods for registration methods.
                ALCClassBuilder *currentClassBuilder = nil;
                NSString *alchemicMethodPrefix = _alchemic_toNSString(ALCHEMIC_PREFIX);
                for (size_t idx = 0; idx < methodCount; ++idx) {

                    // If the method is not an alchemic one, then ignore it.
                    SEL sel = method_getName(classMethods[idx]);
                    if (![NSStringFromSelector(sel) hasPrefix:alchemicMethodPrefix]) {
                        continue;
                    }

                    // If we are here then we have an alchemic method to process, so create a class builder for for the class.
                    if (currentClassBuilder == nil) {
                        STLog(aClass, @"Creating a class builder for a %@ ...", NSStringFromClass(aClass));
                        currentClassBuilder = [[ALCClassBuilder alloc] initWithValueClass:aClass];
                        [context addBuilderToModel:currentClassBuilder];
                    }

                    // Call the method, passing it the current class builder.
                    ((void (*)(id, SEL, ALCClassBuilder *))objc_msgSend)(aClass, sel, currentClassBuilder);

                }

                free(classMethods);

            }];
}

+(nonnull instancetype) dependencyPostProcessorScanner {
    return [[ALCRuntimeScanner alloc]
            initWithSelector:^BOOL(Class  _Nonnull __unsafe_unretained aClass) {
                return [aClass conformsToProtocol:@protocol(ALCDependencyPostProcessor)];
            }
            processor:^(ALCContext * _Nonnull context, Class  _Nonnull __unsafe_unretained aClass) {
                STLog(ALCHEMIC_LOG, @"Adding dependency post processor %@", NSStringFromClass(aClass));
                [context addDependencyPostProcessor:[[aClass alloc] init]];
            }];
}

+(nonnull instancetype) resourceLocatorScanner {
    return [[ALCRuntimeScanner alloc]
            initWithSelector:^BOOL(Class  _Nonnull __unsafe_unretained aClass) {
                return [aClass conformsToProtocol:@protocol(ALCResourceLocator)];
            }
            processor:^(ALCContext * _Nonnull context, Class  _Nonnull __unsafe_unretained aClass) {
                STLog(ALCHEMIC_LOG, @"Adding resource locator %@", NSStringFromClass(aClass));
                //ALCClassBuilder *classBuilder = [context.model createClassBuilderForClass:class inContext:context];
                //classBuilder.value = [[aClass alloc] init];
            }];
}

@end
