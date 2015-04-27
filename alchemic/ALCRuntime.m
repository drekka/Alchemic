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

@implementation ALCRuntime

static Class protocolClass;

+(void) initialize {
    protocolClass = objc_getClass("Protocol");
}

#pragma mark - General

+(const char *) concat:(const char *) left to:(const char *) right {
    
    size_t newStringSize = strlen(left) + strlen(right) + 1;
    char *finalString = malloc(newStringSize);
    strlcat(finalString, left, newStringSize);
    strlcat(finalString, right, newStringSize);
    return finalString;
}

+(SEL) alchemicSelectorForSelector:(SEL) selector {

    const char * prefix = _alchemic_toCharPointer(ALCHEMIC_PREFIX);
    const char * selName = sel_getName(selector);

    char finalString[sizeof(prefix) + sizeof(selName)];
    int bufSize = sizeof(finalString);
    strlcat(finalString, prefix, bufSize);
    strlcat(finalString, selName, bufSize);
    
    logRuntime(@"Registering @selector(%s)", finalString);
    return sel_registerName(finalString);
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

#pragma mark - Alchemic

static const size_t _prefixLength = strlen(_alchemic_toCharPointer(ALCHEMIC_PREFIX));

#pragma mark - Class scanning

+(void) findAlchemicClasses:(void (^)(ALCInstance *)) registerClassBlock {
    
    for (NSBundle *bundle in [NSBundle allBundles]) {

        logRuntime(@"Scanning bundle %@", bundle);
        unsigned int count = 0;
        const char** classes = objc_copyClassNamesForImage([[bundle executablePath] UTF8String], &count);
        
        for(unsigned int i = 0;i < count;i++){

            if (strncmp(classes[i], "ALC", 3) == 0 || strncmp(classes[i], "Alc", 3) == 0) {
                continue;
            }
            
            Class class = objc_getClass(classes[i]);
            ALCInstance *instance = [self executeAlchemicMethodsInClass:class];
            if (instance != nil) {
                registerClassBlock(instance);
            }
        }
    }
}

+(ALCInstance *) executeAlchemicMethodsInClass:(Class) class {
    
    // Get the class methods. We need to get the class of the class for them.
    unsigned int methodCount;
    Method *classMethods = class_copyMethodList(object_getClass(class), &methodCount);
    
    // Search the methods for registration methods.
    ALCInstance *instance = nil;
    for (size_t idx = 0; idx < methodCount; ++idx) {
        
        SEL sel = method_getName(classMethods[idx]);
        const char * methodName = sel_getName(sel);
        if (strncmp(methodName, _alchemic_toCharPointer(ALCHEMIC_PREFIX), _prefixLength) != 0) {
            continue;
        }
        
        if (instance == nil) {
            instance = [[ALCInstance alloc] initWithClass:class];
        }
        
        logRuntime(@"Executing %s::%s ...", class_getName(class), methodName);
        ((void (*)(id, SEL, ALCInstance *))objc_msgSend)(class, sel, instance); // Note cast because of XCode 6
        
    }
    
    free(classMethods);
    return instance;
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
