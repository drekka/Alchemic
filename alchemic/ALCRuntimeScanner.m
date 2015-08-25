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
#import "ALCObjectBuilder.h"
#import "ALCBuilder.h"
#import "ALCInternalMacros.h"
#import "ALCDependencyPostProcessor.h"
#import "ALCResourceLocator.h"
#import "ALCContext.h"
#import "ALCConfig.h"
#import "ALCSingletonStorage.h"
#import "ALCClassInstantiator.h"

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
            processor:^(ALCContext * context, NSMutableSet *moreBundlesClass, Class __unsafe_unretained aClass) {

                // Get the class methods. We need to get the class of the class for them.
                unsigned int methodCount;
                Method *classMethods = class_copyMethodList(object_getClass(aClass), &methodCount);

                // Search the methods for registration methods.
                ALCObjectBuilder *currentClassBuilder = nil;
                NSString *alchemicMethodPrefix = alc_toNSString(ALCHEMIC_PREFIX);
                for (size_t idx = 0; idx < methodCount; ++idx) {

                    // If the method is not an alchemic one, then ignore it.
                    SEL sel = method_getName(classMethods[idx]);
                    if (![NSStringFromSelector(sel) hasPrefix:alchemicMethodPrefix]) {
                        continue;
                    }

                    // If we are here then we have an alchemic method to process, so create a class builder for for the class.
                    if (currentClassBuilder == nil) {
                        STLog(aClass, @"Creating class builder for a %@ ...", NSStringFromClass(aClass));
                        currentClassBuilder = [[ALCObjectBuilder alloc] initWithStorage:[[ALCSingletonStorage alloc] init]
                                                                           instantiator:[[ALCClassInstantiator alloc] initWithObjectType:aClass]
                                                                               forClass:aClass ];
                        [context addBuilderToModel:currentClassBuilder];
                    }

                    // Call the method, passing it the current class builder.
                    ((void (*)(id, SEL, ALCObjectBuilder *))objc_msgSend)(aClass, sel, currentClassBuilder);

                }

                free(classMethods);
            }];
}

+(nonnull instancetype) dependencyPostProcessorScanner {
    return [[ALCRuntimeScanner alloc]
            initWithSelector:^BOOL(Class  _Nonnull __unsafe_unretained aClass) {
                return [aClass conformsToProtocol:@protocol(ALCDependencyPostProcessor)];
            }
            processor:^(ALCContext * context, NSMutableSet *moreBundles, Class __unsafe_unretained aClass) {
                [context addDependencyPostProcessor:[[aClass alloc] init]];
            }];
}

+(nonnull instancetype) resourceLocatorScanner {
    return [[ALCRuntimeScanner alloc]
            initWithSelector:^BOOL(Class  _Nonnull __unsafe_unretained aClass) {
                return [aClass conformsToProtocol:@protocol(ALCResourceLocator)];
            }
            processor:^(ALCContext * context, NSMutableSet *moreBundles, Class __unsafe_unretained aClass) {
                //ALCClassBuilder *classBuilder = [context.model createClassBuilderForClass:class inContext:context];
                //classBuilder.value = [[aClass alloc] init];
            }];
}

+(instancetype) configScanner {
    return [[ALCRuntimeScanner alloc]
            initWithSelector:^BOOL(Class  _Nonnull __unsafe_unretained aClass) {
                return [aClass conformsToProtocol:@protocol(ALCConfig)];
            }
            processor:^(ALCContext * context, NSMutableSet *moreBundles, Class __unsafe_unretained aClass) {
                STLog(ALCHEMIC_LOG, @"Reading config from %@", NSStringFromClass(aClass));
                NSArray<Class> *configClasses = [((id<ALCConfig>)aClass) scanBundlesWithClasses];
                [configClasses enumerateObjectsUsingBlock:^(Class  configClass, NSUInteger idx, BOOL * stop) {
                    NSBundle *bundle = [NSBundle bundleForClass:configClass];
                    [moreBundles addObject:bundle];
                }];
            }];
}

@end
