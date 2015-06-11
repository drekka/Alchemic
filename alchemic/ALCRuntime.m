//
//  AlchemicRuntime.m
//  alchemic
//
//  Created by Derek Clarkson on 11/02/2015.
//  Copyright (c) 2015 Derek Clarkson. All rights reserved.
//

@import ObjectiveC;

#import "ALCRuntime.h"
#import "ALCInternal.h"
#import "ALCClassBuilder.h"
#import "ALCLogger.h"
#import "NSDictionary+ALCModel.h"
#import "ALCModelClassProcessor.h"
#import "ALCClassWithProtocolClassProcessor.h"
#import "ALCResourceLocator.h"

@implementation ALCRuntime

static Class protocolClass;

+(void) initialize {
    protocolClass = objc_getClass("Protocol");
}

#pragma mark - General

+(const char *) concat:(const char *) left to:(const char *) right {
    return [[NSString stringWithFormat:@"%s%s", left, right] cStringUsingEncoding:NSUTF8StringEncoding];
}

+(SEL) alchemicSelectorForSelector:(SEL) selector {
    const char * prefix = _alchemic_toCharPointer(ALCHEMIC_PREFIX);
    const char * selName = sel_getName(selector);
    const char * newSelectorName = [self concat:prefix to:selName];
    return sel_registerName(newSelectorName);
}

+(BOOL) classIsProtocol:(Class) possiblePrototocol {
    return protocolClass == possiblePrototocol;
}

+(Ivar) class:(Class) class withName:(NSString *) name {
    const char * charName = [name UTF8String];
    Ivar var = class_getInstanceVariable(class, charName);
    if (var == NULL) {
        // It may be a class variable.
        var = class_getClassVariable(class, charName);
        if (var == NULL) {
            // It may be a property we have been passed so look for a '_' var.
            var = class_getInstanceVariable(class, [[@"_" stringByAppendingString:name] UTF8String]);
        }
    }
    return var;
}

+(void) injectObject:(id) object variable:(Ivar) variable withValue:(id) value {
    object_setIvar(object, variable, value);
}

+(void) validateMatcher:(id) object {
    if ([object conformsToProtocol:@protocol(ALCMatcher)]) {
        return;
    }
    @throw [NSException exceptionWithName:@"AlchemicNotAMatcher"
                                   reason:[NSString stringWithFormat:@"Passed matcher %s does not conform to the ALCMatcher protocol", object_getClassName(object)]
                                 userInfo:nil];
}

+(void) validateSelector:(SEL) selector withClass:(Class) class {
    if (! class_respondsToSelector(class, selector)) {
        @throw [NSException exceptionWithName:@"AlchemicSelectorNotFound"
                                       reason:[NSString stringWithFormat:@"Faciled to find selector %s::%s", class_getName(class), sel_getName(selector)]
                                     userInfo:nil];
    }
}

+(BOOL) class:(Class) class isKindOfClass:(Class) otherClass {
    Class nextClass = class;
    while (nextClass != nil) {
        if (nextClass == otherClass) {
            return YES;
        }
        nextClass = class_getSuperclass(nextClass);
    }
    return NO;
}

#pragma mark - Class scanning

+(void) scanRuntimeWithContext:(ALCContext *) context {
    
    ClassMatchesBlock initStrategiesBlock = ^(classMatchesBlockArgs){
        [context addInitStrategy:class];
    };
    
    ClassMatchesBlock resolverPostProcessorBlock = ^(classMatchesBlockArgs){
        [context addDependencyPostProcessor:[[class alloc] init]];
    };
    
    ClassMatchesBlock resourceLocatorBlock = ^(classMatchesBlockArgs){
        ALCClassBuilder *classBuilder = [context.model createClassBuilderForClass:class inContext:context];
        classBuilder.value = [[class alloc] init];
    };
    
    ClassMatchesBlock objectFactoryBlock = ^(classMatchesBlockArgs){
        [context addObjectFactory:[[class alloc] init]];
    };
    
    NSSet *processors = [NSSet setWithArray:@[
                                              [[ALCModelClassProcessor alloc] init],
                                              [[ALCClassWithProtocolClassProcessor alloc] initWithProtocol:@protocol(ALCInitStrategy)
                                                                                               whenMatches:initStrategiesBlock],
                                              [[ALCClassWithProtocolClassProcessor alloc] initWithProtocol:@protocol(ALCDependencyPostProcessor)
                                                                                               whenMatches:resolverPostProcessorBlock],
                                              [[ALCClassWithProtocolClassProcessor alloc] initWithProtocol:@protocol(ALCResourceLocator)
                                                                                               whenMatches:resourceLocatorBlock],
                                              [[ALCClassWithProtocolClassProcessor alloc] initWithProtocol:@protocol(ALCObjectFactory)
                                                                                               whenMatches:objectFactoryBlock]
                                              ]];
    
    for (NSBundle *bundle in [NSBundle allBundles]) {
        
        logRuntime(@"Scanning bundle %@", bundle);
        unsigned int count = 0;
        const char** classes = objc_copyClassNamesForImage([[bundle executablePath] UTF8String], &count);
        
        for(unsigned int i = 0;i < count;i++){
            for (id<ALCClassProcessor> processor in processors) {
                [processor processClass:objc_getClass(classes[i]) withContext:context];
            }
        }
    }
}

#pragma mark - Alchemic

+(Ivar) class:(Class) class variableForInjectionPoint:(NSString *) inj {
    
    const char * charName = [inj UTF8String];
    Ivar var = class_getInstanceVariable(class, charName);
    if (var == NULL) {
        // It may be a class variable.
        var = class_getClassVariable(class, charName);
        if (var == NULL) {
            // It may be a property we have been passed so look for a '_' var.
            var = class_getInstanceVariable(class, [[@"_" stringByAppendingString:inj] UTF8String]);
        }
    }
    
    if (var == NULL) {
        @throw [NSException exceptionWithName:@"AlchemicInjectionNotFound"
                                       reason:[NSString stringWithFormat:@"Cannot find variable/property '%@' in class %s", inj, class_getName(class)]
                                     userInfo:nil];
    }
    
    logRegistration(@"   Injection %@ -> variable: %s", inj, ivar_getName(var));
    return var;
}

@end
