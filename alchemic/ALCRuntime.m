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
#import "ALCInstance.h"
#import "ALCLogger.h"
#import "ALCDependency.h"
#import "NSDictionary+ALCModel.h"
#import "ALCContext.h"

#import "ALCModelClassProcessor.h"
#import "ALCInitStrategyClassProcessor.h"

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

+(BOOL) class:(Class) child extends:(Class) parent {
    Class nextParent = child;
    while(nextParent) {
        if (nextParent == parent) {
            return YES;
        }
        nextParent = class_getSuperclass(nextParent);
    }
    return NO;
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

+(void) validateMatcher:(id) object {
    if ([object conformsToProtocol:@protocol(ALCMatcher)]) {
        return;
    }
    @throw [NSException exceptionWithName:@"AlchemicUnableNotAMatcher"
                                   reason:[NSString stringWithFormat:@"Passed matcher %s does not conform to the ALCMatcher protocol", object_getClassName(object)]
                                 userInfo:nil];
}

+(void) executeOnClassHierarchy:(Class) initialClass block:(BOOL (^)(Class class)) classBlock {
    Class nextClass = initialClass;
    while (nextClass != NULL && classBlock(nextClass)) {
        nextClass = class_getSuperclass(nextClass);
    }
}


#pragma mark - Class scanning

+(void) scanRuntimeWithContext:(ALCContext *) context {
    
    NSSet *processors = [NSSet setWithArray:@[
                                              [[ALCModelClassProcessor alloc] init],
                                              [[ALCInitStrategyClassProcessor alloc] init]
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
    
    logRegistration(@"Inject: %@, mapped to variable: %s", inj, ivar_getName(var));
    return var;
}

@end
