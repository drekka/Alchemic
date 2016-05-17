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

#define ALCClassSelectorArgs Class aClass
typedef BOOL (^ALCClassSelector) (ALCClassSelectorArgs);

#define ALCClassProcessorArgs ALCRuntimeScanner *scanner, Class aClass
typedef NSSet<NSBundle *>  * _Nullable (^ALCClassProcessor) (ALCClassProcessorArgs);

@implementation ALCRuntimeScanner {
    ALCClassSelector _classSelector;
    ALCClassProcessor _classProcessor;
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

+(instancetype) modelScannerForContext:(id<ALCContext>) context {
    return [[ALCRuntimeScanner alloc]
            initWithClassSelector:^BOOL(ALCClassSelectorArgs) {
                return YES;
            }
            classProcessor:^NSSet<NSBundle *> *_Nullable (ALCClassProcessorArgs) {
                ALCClassObjectFactory *classObjectFactory;
                [scanner context:context executeAlchemicMethod:aClass classFactory:&classObjectFactory];
                [scanner context:context executeAlchemicRegistrationMethods:aClass classFactory:&classObjectFactory];
                return nil;
            }];
}

+(instancetype) resourceLocatorScannerForContext:(id<ALCContext>) context {
    return [[ALCRuntimeScanner alloc]
            initWithClassSelector:^BOOL(ALCClassSelectorArgs) {
                return NO;
                //return [aClass conformsToProtocol:@protocol(ALCResourceLocator)];
            }
            classProcessor:^NSSet<NSBundle *> *_Nullable (ALCClassProcessorArgs) {
                //ALCBuilder *classBuilder = [context.model createClassBuilderForClass:class inContext:context];
                //classBuilder.value = [[aClass alloc] init];
                return nil;
            }];
}

+(instancetype) configScannerForContext:(id<ALCContext>) context {
    return [[ALCRuntimeScanner alloc]
            initWithClassSelector:^BOOL(ALCClassSelectorArgs) {
                return [aClass conformsToProtocol:@protocol(ALCConfig)];
            }
            classProcessor:^NSSet<NSBundle *> *_Nullable (ALCClassProcessorArgs) {
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

#pragma mark - Initializer

-(instancetype) initWithClassSelector:(ALCClassSelector) classSelector
                               classProcessor:(ALCClassProcessor) classProcessor {
    self = [super init];
    if (self) {
        _classSelector = classSelector;
        _classProcessor = classProcessor;
    }
    return self;
}

#pragma mark - Tasks

-(nullable NSSet<NSBundle *> *) scanClass:(Class) aClass {
    return _classSelector(aClass) ? _classProcessor(self, aClass) : nil;
}

-(void) context:(id<ALCContext>) context executeAlchemicMethod:(Class) inClass classFactory:(ALCClassObjectFactory **) factory {
    
    AcIgnoreSelectorWarnings(
                             SEL alchemicFunctionSelector = @selector(alchemic:);
                             )
    if (![inClass respondsToSelector:alchemicFunctionSelector]) {
        return;
    }
    
    STLog(inClass, @"Class %@ has alchemic() method, executing", NSStringFromClass(inClass));
    if (!*factory) {
        *factory = [context registerObjectFactoryForClass:inClass];
    }
    
    // Call the function.
    ((void (*)(id, SEL, ALCClassObjectFactory *))objc_msgSend)(inClass, alchemicFunctionSelector, *factory);
}

-(void) context:(id<ALCContext>) context executeAlchemicRegistrationMethods:(Class) inClass classFactory:(ALCClassObjectFactory **) factory {
    
    // Get the class methods. We need to get the class of the class for them.
    unsigned int methodCount;
    Method *classMethods = class_copyMethodList(object_getClass(inClass), &methodCount);
    
    // Search the methods for alchemic methods. Their presence triggers registrations.
    for (size_t idx = 0; idx < methodCount; idx++) {
        
        // If the method is not an alchemic one, then ignore it.
        SEL nextSelector = method_getName(classMethods[idx]);
        if (![NSStringFromSelector(nextSelector) hasPrefix:alc_toNSString(ALCHEMIC_PREFIX)]) {
            continue;
        }
        
        // If we are here then we have an alchemic method to process, so create a class builder for for the class.
        STLog(inClass, @"Class %@ has alchemic methods", NSStringFromClass(inClass));
        if (!*factory) {
            *factory = [context registerObjectFactoryForClass:inClass];
        }
        
        // Call the method, passing it the current class builder.
        ((void (*)(id, SEL, ALCClassObjectFactory *))objc_msgSend)(inClass, nextSelector, *factory);
        
    }
    
    free(classMethods);
}

@end

NS_ASSUME_NONNULL_END
