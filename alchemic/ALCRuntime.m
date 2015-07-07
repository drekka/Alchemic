//
//  AlchemicRuntime.m
//  alchemic
//
//  Created by Derek Clarkson on 11/02/2015.
//  Copyright (c) 2015 Derek Clarkson. All rights reserved.
//

@import ObjectiveC;

#import "ALCRuntime.h"
#import <Alchemic/ALCInternal.h>
#import <Alchemic/ALCContext.h>
#import "ALCClassBuilder.h"
#import <StoryTeller/StoryTeller.h>
#import "ALCModelClassProcessor.h"
#import "ALCClassWithProtocolClassProcessor.h"
#import "ALCResourceLocator.h"

@implementation ALCRuntime

static Class __protocolClass;
static NSCharacterSet *__typeEncodingDelimiters;

+(void) initialize {
    __protocolClass = objc_getClass("Protocol");
    __typeEncodingDelimiters = [NSCharacterSet characterSetWithCharactersInString:@"@\",<>"];
}

#pragma mark - Checking and querying

+(BOOL) objectIsAClass:(id __nonnull) possibleClass {
    // Must use getClass here to access the meta class which is how we detect class objects.
    return class_isMetaClass(object_getClass(possibleClass));
}

+(BOOL) objectIsAProtocol:(id __nonnull) possiblePrototocol {
    return __protocolClass == [possiblePrototocol class];
}

+(BOOL) aClass:(Class __nonnull) aClass isKindOfClass:(Class __nonnull) otherClass {
    return [aClass isKindOfClass:otherClass];
//    Class nextClass = aClass;
//    while (nextClass != nil) {
//        if (nextClass == otherClass) {
//            return YES;
//        }
//        nextClass = class_getSuperclass(nextClass);
//    }
//    return NO;
}

+(BOOL) aClass:(Class __nonnull) aClass conformsToProtocol:(Protocol __nonnull *) protocol {
    return [aClass conformsToProtocol:protocol];
}

+(void) aClass:(Class __nonnull) class validateSelector:(SEL __nonnull) selector {
    if (! class_respondsToSelector(class, selector)) {
        @throw [NSException exceptionWithName:@"AlchemicSelectorNotFound"
                                       reason:[NSString stringWithFormat:@"Faciled to find selector %s::%s", class_getName(class), sel_getName(selector)]
                                     userInfo:nil];
    }
}

+(nullable Class) iVarClass:(Ivar __nonnull) ivar {

    // Get the type.
    NSArray *iVarTypes = [self typesForIVar:ivar];
    if (iVarTypes == nil) {
        return nil;
    }

    // Must have some type information returned.
    return iVarTypes[0];
}

+(nonnull NSSet<Protocol *> *) aClassProtocols:(Class __nonnull) aClass {

    NSMutableSet<Protocol *> *protocols = [[NSMutableSet<Protocol *> alloc] init];

    [self aClass:aClass executeOnHierarchy:^BOOL(__unsafe_unretained Class nextClass) {
        unsigned int protocolCount;
        Protocol * __unsafe_unretained *protocolList = class_copyProtocolList(nextClass, &protocolCount);
        if (protocolCount > 0) {
            for (unsigned int i = 0; i < protocolCount; i++) {
                [protocols addObject:protocolList[i]];
            }
            free(protocolList);
        }
        return NO;
    }];


    return protocols;
}


#pragma mark - General

+(void) object:(id __nonnull) object injectVariable:(Ivar __nonnull) variable withValue:(id __nullable) value {
    object_setIvar(object, variable, value);
}

+(SEL) alchemicSelectorForSelector:(SEL) selector {
    const char * prefix = _alchemic_toCharPointer(ALCHEMIC_PREFIX);
    const char * selName = sel_getName(selector);
    const char * newSelectorName = [NSString stringWithFormat:@"%s%s", prefix, selName].UTF8String;
    return sel_registerName(newSelectorName);
}


+(void) scanRuntimeWithContext:(ALCContext __nonnull *) context {

    ClassMatchesBlock initStrategiesBlock = ^(classMatchesBlockArgs){
        [context addInitStrategy:class];
    };

    ClassMatchesBlock resolverPostProcessorBlock = ^(classMatchesBlockArgs){
        [context addDependencyPostProcessor:[[class alloc] init]];
    };

    /*
     ClassMatchesBlock resourceLocatorBlock = ^(classMatchesBlockArgs){
     ALCClassBuilder *classBuilder = [context.model createClassBuilderForClass:class inContext:context];
     classBuilder.value = [[class alloc] init];
     };
     */

    ClassMatchesBlock objectFactoryBlock = ^(classMatchesBlockArgs){
        [context addObjectFactory:[[class alloc] init]];
    };

    NSSet *processors = [NSSet setWithArray:@[
                                              [[ALCModelClassProcessor alloc] init],
                                              [[ALCClassWithProtocolClassProcessor alloc] initWithProtocol:@protocol(ALCInitStrategy)
                                                                                               whenMatches:initStrategiesBlock],
                                              [[ALCClassWithProtocolClassProcessor alloc] initWithProtocol:@protocol(ALCDependencyPostProcessor)
                                                                                               whenMatches:resolverPostProcessorBlock],
                                              // [[ALCClassWithProtocolClassProcessor alloc] initWithProtocol:@protocol(ALCResourceLocator)
                                              //                                                 whenMatches:resourceLocatorBlock],
                                              [[ALCClassWithProtocolClassProcessor alloc] initWithProtocol:@protocol(ALCObjectFactory)
                                                                                               whenMatches:objectFactoryBlock]
                                              ]];

    for (NSBundle *bundle in [NSBundle allBundles]) {

        STLog(ALCHEMIC_LOG, @"Scanning bundle %@", bundle);
        unsigned int count = 0;
        const char** classes = objc_copyClassNamesForImage([[bundle executablePath] UTF8String], &count);

        for(unsigned int i = 0;i < count;i++){
            for (id<ALCClassProcessor> processor in processors) {
                [processor processClass:objc_getClass(classes[i]) withContext:context];
            }
        }
    }
}

+(nullable Ivar) aClass:(Class __nonnull) aClass variableForInjectionPoint:(NSString __nonnull *) inj {

    const char * charName = [inj UTF8String];
    Ivar var = class_getInstanceVariable(aClass, charName);
    if (var == NULL) {

        // try for a property which may have a completely different variable name.
        objc_property_t prop = class_getProperty(aClass, charName);
        if (prop != NULL) {
            const char *propVarName = property_copyAttributeValue(prop, "V");
            var = class_getInstanceVariable(aClass, propVarName);
        }

        if (var == NULL) {
            // Not a property so it may be a class variable.
            var = class_getClassVariable(aClass, charName);

            if (var == NULL) {
                // Still no luck so try for an underscore prefixed variable.
                var = class_getInstanceVariable(aClass, [[@"_" stringByAppendingString:inj] UTF8String]);
            }
        }
    }

    if (var == NULL) {
        @throw [NSException exceptionWithName:@"AlchemicInjectionNotFound"
                                       reason:[NSString stringWithFormat:@"Cannot find variable/property '%@' in class %s", inj, class_getName(aClass)]
                                     userInfo:nil];
    }

    STLog(aClass, @"Injection %@ -> variable: %s", inj, ivar_getName(var));
    return var;
}

#pragma mark - Qualifiers

+(nonnull NSSet<ALCQualifier *> *) qualifiersForClass:(Class __nonnull) class {
    NSMutableSet<ALCQualifier *> * qualifiers = [[NSMutableSet<ALCQualifier *> alloc] init];
    [qualifiers addObject:[ALCQualifier qualifierWithValue:class]];
    for (Protocol *protocol in [self aClassProtocols:class]) {
        [qualifiers addObject:[ALCQualifier qualifierWithValue:protocol]];
    }
    return qualifiers;
}

+(nonnull NSSet<ALCQualifier *> *) qualifiersForVariable:(Ivar __nonnull)variable {

    NSMutableSet<ALCQualifier *> * qualifiers = [[NSMutableSet<ALCQualifier *> alloc] init];

    // Get the type.
    NSArray *iVarTypes = [self typesForIVar:variable];
    if (iVarTypes == nil) {
        return qualifiers;
    }

    // Must have some type information returned.
    [qualifiers addObject:[ALCQualifier qualifierWithValue:iVarTypes[0]]];
    for (unsigned long i = 1; i < [iVarTypes count];i++) {
        [qualifiers addObject:[ALCQualifier qualifierWithValue:iVarTypes[i]]];
    }
    return qualifiers;
}

+(nullable NSArray *) typesForIVar:(Ivar __nonnull) iVar {

    // Get the type.
    NSString *variableTypeEncoding = [NSString stringWithUTF8String:ivar_getTypeEncoding(iVar)];
    if ([variableTypeEncoding hasPrefix:@"@"]) {

        // Start with a result that indicates an Id. We map Ids as NSObjects.
        NSMutableArray *results = [NSMutableArray arrayWithObject:[NSObject class]];

        // Object type.
        NSArray<NSString *> *defs = [variableTypeEncoding componentsSeparatedByCharactersInSet:__typeEncodingDelimiters];

        // If there is no more than 2 in the array then the dependency is an id.
        // Position 3 will be a class name, positions beyond that will be protocols.
        for (NSUInteger i = 2; i < [defs count]; i ++) {
            if ([defs[i] length] > 0) {
                if (i == 2) {
                    results[0] = objc_lookUpClass(defs[2].UTF8String);
                } else {
                    [results addObject:objc_getProtocol(defs[i].UTF8String)];
                }
            }
        }
        return results;
    }

    // Non object variable.
    return nil;

}

/**
 Executes a block on the class hierarchy starting with the current class and working through the super class structure.

 @param aClass				the class to start with.
 @param executeBlock	the block to execute. Return a YES from this block to stop processing.
 */
+(void) aClass:(Class __nonnull) aClass executeOnHierarchy:(BOOL (^ __nonnull)(Class nextClass)) executeBlock {
    Class nextClass = aClass;
    while (nextClass != nil && ! executeBlock(nextClass)) {
        nextClass = class_getSuperclass(nextClass);
    }
}

@end
