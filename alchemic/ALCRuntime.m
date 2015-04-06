//
//  AlchemicRuntime.m
//  alchemic
//
//  Created by Derek Clarkson on 11/02/2015.
//  Copyright (c) 2015 Derek Clarkson. All rights reserved.
//

#import <objc/runtime.h>
#import <objc/message.h>

#import "ALCRuntime.h"
#import "ALCInternal.h"
#import "ALCInstance.h"
#import "ALCInitialisationStrategyInjector.h"
#import "ALCLogger.h"
#import "ALCDependency.h"
#import "NSMutableDictionary+ALCModel.h"
#import "ALCDependencyResolver.h"

@implementation ALCRuntime

#pragma mark - General

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

#pragma mark - Alchemic

static const size_t _prefixLength = strlen(toCharPointer(ALCHEMIC_METHOD_PREFIX));

#pragma mark - Class scanning

+(void) scanForMacros {
    
    logRuntime(@"Scanning for alchemic methods in runtime");
    
    // Find out how many classes there are in total.
    int numClasses = objc_getClassList(NULL, 0);
    
    // Allocate the memory to contain an array of the classes found.
    Class * classes = (__unsafe_unretained Class *) malloc(sizeof(Class) * (unsigned long) numClasses);
    
    // Now load the array with the classes.
    numClasses = objc_getClassList(classes, numClasses);
    
    // Now scan them.
    Class nextClass;
    for (int index = 0; index < numClasses; index++) {
        
        nextClass = classes[index];
        
        if (nextClass == NULL) {
            continue;
        }
        
        // Exempt system and known classes.
        if ([ALCRuntime isClassIgnorable:nextClass]) {
            continue;
        }
        
        // Look for injection points in class.
        [ALCRuntime checkClassForRegistrations:nextClass];
        
    }
    
    // Free the array.
    free(classes);
}

+(BOOL) isClassIgnorable:(Class) class {
    // Ignore if the class if it's a know system class.
    const char *className = class_getName(class);
    return
    strncmp(className, "NS", 2) == 0
    || strncmp(className, "UI", 2) == 0
    || strncmp(className, "CF", 2) == 0
    || strncmp(className, "XC", 2) == 0
    || strncmp(className, "OS", 2) == 0
    || strncmp(className, "_", 1) == 0
    || strncmp(className, "Alchemic", 8) == 0;
}

+(void) checkClassForRegistrations:(Class) class {
    
    // Get the class methods.
    unsigned int methodCount;
    Method *classMethods = class_copyMethodList(object_getClass(class), &methodCount);
    
    // Search the methods for registration methods.
    Method currMethod;
    SEL sel;
    for (size_t idx = 0; idx < methodCount; ++idx) {
        
        currMethod = classMethods[idx];
        sel = method_getName(currMethod);
        const char * methodName = sel_getName(sel);
        if (strncmp(methodName, toCharPointer(ALCHEMIC_METHOD_PREFIX), _prefixLength) != 0) {
            continue;
        }
        logRuntime(@"Found %s::%s, executing ...", class_getName(class), methodName);
        ((void (*)(id, SEL))objc_msgSend)(class, sel); // Note cast because of XCode 6
        
    }
    
    free(classMethods);
}

static const char * dependenciesProperty = "_alchemic_dependencies";

static const char *injectDependencies = "_alchemic_injectUsingDependencyInjectors:";
static const char *injectDependenciesSig = "v@:@";
static const char *addInjection = "_alchemic_addinjection:withQualifier:";
static const char *addInjectionSig = "v@::@@";
static const char *resolveDependencies = "_alchemic_resolveDependenciesWithModel:dependencyResolvers:";
static const char *resolveDependenciesSig = "v@:@@";

static SEL injectDependenciesSelector;
static SEL addInjectionSelector;
static SEL resolveDependenciesSelector;

void _alchemic_addInjectionWithQualifierImpl(id futureSelfClass, SEL cmd, NSString *inj, NSArray *qualifiers);
void _alchemic_resolveDependenciesWithResolversImpl(id futureSelfClass, SEL cmd, NSArray *dependencyResolvers);
void _alchemic_injectDependenciesWithInjectorsImpl(id futureSelf, SEL cmd, NSArray *dependencyInjectors);

static Class protocolClass;

+(void) initialize {
    logRuntime(@"Setting selectors");
    injectDependenciesSelector = sel_registerName(injectDependencies);
    addInjectionSelector = sel_registerName(addInjection);
    resolveDependenciesSelector = sel_registerName(resolveDependencies);
    protocolClass = objc_getClass("Protocol");
}

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
    
    return var;
}

+(BOOL) classIsProtocol:(Class) possiblePrototocol {
    return protocolClass == possiblePrototocol;
}

#pragma mark - Alchemic

+(BOOL) isClassDecorated:(Class) class {
    return class_respondsToSelector(class, injectDependenciesSelector);
}

+(void) decorateClass:(Class) class {
    
    logRuntime(@"Decorating %s", class_getName(class));
    class_addMethod(class, injectDependenciesSelector, (IMP) _alchemic_injectDependenciesWithInjectorsImpl, injectDependenciesSig);
    
    // Class methods are added by adding to the meta class.
    Class metaClass = object_getClass(class);
    class_addMethod(metaClass, addInjectionSelector, (IMP) _alchemic_addInjectionWithQualifierImpl, addInjectionSig);
    class_addMethod(metaClass, resolveDependenciesSelector, (IMP) _alchemic_resolveDependenciesWithResolversImpl, resolveDependenciesSig);
    
    NSMutableArray *dependencies = [[NSMutableArray alloc] init];
    objc_setAssociatedObject(class, dependenciesProperty, dependencies, OBJC_ASSOCIATION_RETAIN_NONATOMIC);

}

+(void) class:(Class) class addInjection:(NSString *) inj withQualifiers:(NSArray *) qualifiers {
    ((void (*)(id, SEL, NSString *, NSArray *))objc_msgSend)(class, addInjectionSelector, inj, qualifiers);
}

+(void) class:(Class) class resolveDependenciesWithResolvers:(NSArray *) dependencyResolvers {
    ((void (*)(id, SEL, NSArray *))objc_msgSend)(class, resolveDependenciesSelector, dependencyResolvers);
}

+(void) object:(id) object injectUsingDependencyInjectors:(NSArray *) dependencyInjectors {
    ((void (*)(id, SEL, NSArray *))objc_msgSend)(object, injectDependenciesSelector, dependencyInjectors);
}

#pragma mark - Implementations

void _alchemic_addInjectionWithQualifierImpl(id futureSelfClass, SEL cmd, NSString *inj, NSArray *qualifiers) {

    // Create the dependency info to be store.
    Ivar variable = [ALCRuntime class:futureSelfClass variableForInjectionPoint:inj];
    ALCDependency *dependency = [[ALCDependency alloc] initWithVariable:variable];
    
    // If there are qualifiers then clear the pre-loaded settings sort through them.
    if ([qualifiers count] > 0) {
        [dependency setNewResolvingQualifiers:qualifiers];
    }
    
    // Store the dependency.
    logRegistration(@"Adding future injection into %s::%s", class_getName(futureSelfClass), ivar_getName(variable));
    NSMutableArray *dependencies = objc_getAssociatedObject(futureSelfClass, dependenciesProperty);
    [dependencies addObject:dependency];
}


void _alchemic_resolveDependenciesWithResolversImpl(id futureSelfClass, SEL cmd, NSArray *dependencyResolvers) {
    NSMutableArray *dependencies = objc_getAssociatedObject(futureSelfClass, dependenciesProperty);
    for (ALCDependency *dependency in dependencies) {
        [dependency resolveUsingResolvers:dependencyResolvers];
    }
}

// Note this is an instance method. Unlike the ones above which are class methods.
void _alchemic_injectDependenciesWithInjectorsImpl(id futureSelf, SEL cmd, NSArray *dependencyInjectors) {
    NSMutableArray *dependencies = objc_getAssociatedObject([futureSelf class], dependenciesProperty);
    for (ALCDependency *dependency in dependencies) {
        [dependency injectObject:futureSelf usingInjectors:dependencyInjectors];
    }
}

@end
