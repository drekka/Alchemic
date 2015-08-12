//
//  AlchemicRuntime.m
//  alchemic
//
//  Created by Derek Clarkson on 11/02/2015.
//  Copyright (c) 2015 Derek Clarkson. All rights reserved.
//

@import ObjectiveC;
#import <StoryTeller/StoryTeller.h>

#import "ALCRuntime.h"
#import "ALCClassBuilder.h"
#import "ALCRuntimeScanner.h"
#import "ALCInternalMacros.h"
#import "ALCContext.h"
#import "ALCProtocol.h"
#import "ALCConfig.h"
#import "ALCClass.h"

NS_ASSUME_NONNULL_BEGIN

@implementation ALCRuntime

static Class __protocolClass;
static NSCharacterSet *__typeEncodingDelimiters;

+(void) initialize {
    __protocolClass = objc_getClass("Protocol");
    __typeEncodingDelimiters = [NSCharacterSet characterSetWithCharactersInString:@"@\",<>"];
}

#pragma mark - Checking and querying

+(BOOL) objectIsAClass:(id) possibleClass {
    // Must use getClass here to access the meta class which is how we detect class objects.
    return class_isMetaClass(object_getClass(possibleClass));
}

+(BOOL) objectIsAProtocol:(id) possibleProtocol {
    return __protocolClass == [possibleProtocol class];
}

+(nullable Class) iVarClass:(Ivar) ivar {

    // Get the type.
    NSArray *iVarTypes = [self typesForIVar:ivar];
    if (iVarTypes == nil) {
        return nil;
    }

    // Must have some type information returned.
    return iVarTypes[0];
}

+(NSSet<Protocol *> *) aClassProtocols:(Class) aClass {

    NSMutableSet<Protocol *> *protocols = [[NSMutableSet<Protocol *> alloc] init];

    [self aClass:aClass executeOnHierarchy:^BOOL(__unsafe_unretained Class nextClass) {

        // Ignore and exit on NSObject.
        if (nextClass == [NSObject class]) {
            return YES;
        }

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

+(void) object:(id) object injectVariable:(Ivar) variable withValue:(id) value {
	STLog([object class], @"Injecting %@.%s", NSStringFromClass([value class]), ivar_getName(variable));
    object_setIvar(object, variable, value);
}

+(nullable Ivar) aClass:(Class) aClass variableForInjectionPoint:(NSString *) inj {

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

    STLog(aClass, @"Mapping name %@ -> variable: %s", inj, ivar_getName(var));
    return var;
}

#pragma mark - Scanning

+(void) scanRuntimeWithContext:(ALCContext *) context runtimeScanners:(NSSet<ALCRuntimeScanner *> *) runtimeScanners {

    // Define a block for processing a class.
    void (^classScanners)(ALCContext *, Class) = ^(ALCContext *scanContext, Class scanClass) {
        for (ALCRuntimeScanner *scanner in runtimeScanners) {
            if (scanner.selector(scanClass)) {
                scanner.processor(scanContext, scanClass);
            }
        }
    };

    // Use the app bundles and Alchemic framework as the base bundles to search configs classes.
    NSArray<NSBundle *> *appBundles = [NSBundle allBundles];
    appBundles = [appBundles arrayByAddingObject:[NSBundle bundleForClass:[ALCContext class]]];

    // Scan each bundle, checking each class in the bundle.
    NSMutableSet<NSBundle *> *scannedBundles = [NSMutableSet setWithArray:appBundles];
    Protocol *configProtocol = @protocol(ALCConfig);
    [self scanBundles:appBundles withClassBlock:^(Class  __unsafe_unretained aClass) {

        // Check the class for Alchemic methods.
        classScanners(context, aClass);

        // Now check to see if it's an Alchemic config class.

        // TODO: Can we create another scanner intance to do this?

        if ([aClass conformsToProtocol:configProtocol]) {

            // Found a config, get a list of classes from the config that define additional bundles to scan.
            NSArray<Class> *configClasses = [((id<ALCConfig>)aClass) scanBundlesWithClasses];
            [configClasses enumerateObjectsUsingBlock:^(Class  configClass, NSUInteger idx, BOOL * stop) {

                // If the config bundle is not already scanned then scan it.
                NSBundle *additionalBundle = [NSBundle bundleForClass:configClass];
                if (![scannedBundles containsObject:additionalBundle]) {
                    [scannedBundles addObject:additionalBundle];
                    [self scanBundles:@[additionalBundle] withClassBlock:^(Class  __unsafe_unretained additionalClass) {
                        classScanners(context, additionalClass);
                    }];
                }
            }];
        }
    }];

}

+(void) scanBundles:(NSArray<NSBundle *> *) bundles withClassBlock:(void(^)(Class aClass)) classBlock {
    for (NSBundle *bundle in bundles) {
        STLog(ALCHEMIC_LOG, @"Scanning bundle %@", bundle.bundlePath.lastPathComponent);
        unsigned int count = 0;
        const char** classes = objc_copyClassNamesForImage([[bundle executablePath] UTF8String], &count);
        for(unsigned int i = 0;i < count;i++){
            classBlock(objc_getClass(classes[i]));
        }
    }
}

#pragma mark - Qualifiers

+(NSSet<id<ALCModelSearchExpression>> *) searchExpressionsForClass:(Class) aClass {
    STLog(aClass, @"Generating search expressions for class: %@", NSStringFromClass(aClass));
    NSMutableSet<id<ALCModelSearchExpression>> * expressions = [[NSMutableSet alloc] init];
    [expressions addObject:[ALCClass withClass:aClass]];
    for (Protocol *protocol in [self aClassProtocols:aClass]) {
        [expressions addObject:[ALCProtocol withProtocol:protocol]];
    }
    return expressions;
}

+(NSSet<id<ALCModelSearchExpression>> *) searchExpressionsForVariable:(Ivar)variable {

    STLog(ALCHEMIC_LOG, @"Generating search expressions for variable: %s", ivar_getName(variable));
    NSMutableSet<id<ALCModelSearchExpression>> *expressions = [[NSMutableSet alloc] init];

    // Get the type.
    NSArray *iVarTypes = [self typesForIVar:variable];
    if (iVarTypes == nil) {
        return expressions;
    }

    // Must have some type information returned.
    [expressions addObject:[ALCClass withClass:iVarTypes[0]]];
    for (unsigned long i = 1; i < [iVarTypes count];i++) {
        [expressions addObject:[ALCProtocol withProtocol:iVarTypes[i]]];
    }
    return expressions;
}

+(nullable NSArray *) typesForIVar:(Ivar) iVar {

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
+(void) aClass:(Class) aClass executeOnHierarchy:(BOOL (^)(Class nextClass)) executeBlock {
    Class nextClass = aClass;
    while (nextClass != nil && ! executeBlock(nextClass)) {
        nextClass = class_getSuperclass(nextClass);
    }
}

@end

NS_ASSUME_NONNULL_END