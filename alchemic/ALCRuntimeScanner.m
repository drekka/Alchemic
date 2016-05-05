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
#import "ALCMacros.h"
#import "ALCInternalMacros.h"
#import "ALCContext.h"
#import "ALCConfig.h"
#import "NSBundle+Alchemic.h"
#import "NSSet+Alchemic.h"

NS_ASSUME_NONNULL_BEGIN

typedef BOOL (^ALCClassSelector) (Class aClass);
typedef NSSet<NSBundle *>  * _Nullable (^ALCClassProcessor) (Class aClass);

@implementation ALCRuntimeScanner {
    ALCClassSelector _classSelector;
    ALCClassProcessor _classProcessor;
}

-(nonnull instancetype) initWithClassSelector:(nonnull ALCClassSelector) classSelector
                               classProcessor:(nonnull ALCClassProcessor) classProcessor {
    self = [super init];
    if (self) {
        _classSelector = classSelector;
        _classProcessor = classProcessor;
    }
    return self;
}

-(nullable NSSet<NSBundle *> *) scanClass:(Class) aClass {
    return _classSelector(aClass) ? _classProcessor(aClass) : nil;
}

+(nullable NSSet<NSBundle *> *) scanBundles:(NSSet<NSBundle *> *) bundles context:(id<ALCContext>) context {

    NSArray<ALCRuntimeScanner *> *scanners = @[
                                               [self modelScannerForContext:context],
                                               [self resourceLocatorScannerForContext:context],
                                               [self configScannerForContext:context]
                                               ];
    NSMutableSet<NSBundle *> *moreBundles;
    for (NSBundle *bundle in bundles) {
        [NSSet unionSet:[bundle scanWithScanners:scanners] intoMutableSet:&moreBundles];
    }
    return moreBundles;
}

#pragma mark - Factory methods

+(nonnull instancetype) modelScannerForContext:(id<ALCContext>) context {
    AcIgnoreSelectorWarnings(
                           SEL alchemicFunctionSelector = @selector(alchemic:);
                           )
    return [[ALCRuntimeScanner alloc]
            initWithClassSelector:^BOOL(Class aClass) {
                return YES;
            }
            classProcessor:^NSSet<NSBundle *> *_Nullable (Class aClass) {

                // First check for a swift based call.
                if ([aClass respondsToSelector:alchemicFunctionSelector]) {
                    STLog(aClass, @"Swift class %@ has alchemic() method, executing it ...", NSStringFromClass(aClass));
                    ALCClassObjectFactory *objectFactory = [context registerObjectFactoryForClass:aClass];
                    AcIgnoreSelectorWarnings(
                                           SEL selector = @selector(alchemic:);
                                           ((void (*)(id, SEL, ALCClassObjectFactory *))objc_msgSend)(aClass, selector, objectFactory);
                                           )
                    return nil;
                }

                // Get the class methods. We need to get the class of the class for them.
                unsigned int methodCount;
                Method *classMethods = class_copyMethodList(object_getClass(aClass), &methodCount);

                // Search the methods for alchemic methods. Their presence triggers registrations.
                ALCClassObjectFactory *classObjectFactory;
                for (size_t idx = 0; idx < methodCount; idx++) {

                    // If the method is not an alchemic one, then ignore it.
                    SEL nextSelector = method_getName(classMethods[idx]);
                    if (![NSStringFromSelector(nextSelector) hasPrefix:alc_toNSString(ALCHEMIC_PREFIX)]) {
                        continue;
                    }

                    // If we are here then we have an alchemic method to process, so create a class builder for for the class.
                    if (classObjectFactory == nil) {
                        STLog(aClass, @"Class %@ has Alchemic methods", NSStringFromClass(aClass));
                        classObjectFactory = [context registerObjectFactoryForClass:aClass];
                    }

                    // Call the method, passing it the current class builder.
                    ((void (*)(id, SEL, ALCClassObjectFactory *))objc_msgSend)(aClass, nextSelector, classObjectFactory);

                }

                free(classMethods);
                return nil;
            }];
}

+(nonnull instancetype) resourceLocatorScannerForContext:(id<ALCContext>) context {
    return [[ALCRuntimeScanner alloc]
            initWithClassSelector:^BOOL(Class aClass) {
                return NO;
                //return [aClass conformsToProtocol:@protocol(ALCResourceLocator)];
            }
            classProcessor:^NSSet<NSBundle *> *_Nullable (Class aClass) {
                //ALCBuilder *classBuilder = [context.model createClassBuilderForClass:class inContext:context];
                //classBuilder.value = [[aClass alloc] init];
                return nil;
            }];
}

+(nonnull instancetype) configScannerForContext:(id<ALCContext>) context {
    return [[ALCRuntimeScanner alloc]
            initWithClassSelector:^BOOL(Class aClass) {
                return [aClass conformsToProtocol:@protocol(ALCConfig)];
            }
            classProcessor:^NSSet<NSBundle *> *_Nullable (Class aClass) {
                STLog(self, @"Reading config from %@", NSStringFromClass(aClass));
                NSMutableSet<NSBundle *> *moreBundles;
                NSArray<Class> *configClasses = [((id<ALCConfig>)aClass) scanBundlesWithClasses];
                if (configClasses) {
                    moreBundles = [[NSMutableSet alloc] initWithCapacity:configClasses.count];
                    for (Class nextClass in [((id<ALCConfig>)aClass) scanBundlesWithClasses]) {
                        [moreBundles addObject:[NSBundle bundleForClass:nextClass]];
                    };
                }
                return moreBundles;
            }];
}

@end

NS_ASSUME_NONNULL_END
