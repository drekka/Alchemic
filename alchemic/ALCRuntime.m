//
//  ALCRuntime.m
//  Alchemic
//
//  Created by Derek Clarkson on 5/02/2016.
//  Copyright © 2016 Derek Clarkson. All rights reserved.
//

#import "ALCRuntime.h"
#import "ALCInternalMacros.h"
#import "ALCTypeData.h"
#import "ALCContext.h"
#import "ALCRuntimeScanner.h"
#import "NSSet+Alchemic.h"

NS_ASSUME_NONNULL_BEGIN

@implementation ALCRuntime

static Class __protocolClass;
static NSCharacterSet *__typeEncodingDelimiters;

+(void) initialize {
    __protocolClass = objc_getClass("Protocol");
    __typeEncodingDelimiters = [NSCharacterSet characterSetWithCharactersInString:@"@\",<>"];
}

+(Ivar) aClass:(Class) aClass variableForInjectionPoint:(NSString *) inj {

    // First attempt to get an instance variable with the passed name
    const char * charName = [inj UTF8String];
    Ivar var = class_getInstanceVariable(aClass, charName);
    if (var) {
        return var;
    }

    // Not found, so try for a property based on the passed name.
    // The property's internal variable may have a completely different variable name.
    objc_property_t prop = class_getProperty(aClass, charName);
    if (prop) {
        // Return the internal variable.
        const char *propVarName = property_copyAttributeValue(prop, "V");
        return class_getInstanceVariable(aClass, propVarName);
    }

    // Not a property so it may be a static class variable.
    var = class_getClassVariable(aClass, charName);
    if (var) {
        return var;
    }

    // Still no luck so last attempt, try for an underscore prefixed variable.
    var = class_getInstanceVariable(aClass, [[@"_" stringByAppendingString:inj] UTF8String]);

    if (var == NULL) {
        throwException(@"AlchemicInjectionNotFound", @"Cannot find variable/property '%@' in class %s", inj, class_getName(aClass));
    }

    return var;
}

+(ALCTypeData *) typeDataForIVar:(Ivar) iVar {
    NSString *variableTypeEncoding = [NSString stringWithUTF8String:ivar_getTypeEncoding(iVar)];
    return [self typeDataForEncoding:variableTypeEncoding];
}

+(ALCTypeData *) typeDataForEncoding:(NSString *) encoding {

    // Get the type.
    ALCTypeData *typeData = [[ALCTypeData alloc] init];
    if ([encoding hasPrefix:@"@"]) {

        // Start with a result that indicates an Id. We map Ids as NSObjects.
        typeData.objcClass = [NSObject class];

        // Object type.
        NSArray<NSString *> *defs = [encoding componentsSeparatedByCharactersInSet:__typeEncodingDelimiters];

        // If there is no more than 2 in the array then the dependency is an id.
        // Position 3 will be a class name, positions beyond that will be protocols.
        for (NSUInteger i = 2; i < [defs count]; i ++) {
            if ([defs[i] length] > 0) {
                if (i == 2) {
                    // Update the class.
                    typeData.objcClass = objc_lookUpClass(defs[2].UTF8String);
                } else {
                    if (!typeData.objcProtocols) {
                        typeData.objcProtocols = [[NSMutableArray alloc] init];
                    }
                    [(NSMutableArray *)typeData.objcProtocols addObject:objc_getProtocol(defs[i].UTF8String)];
                }
            }
        }
        return typeData;
    }

    // Not an object type.
    typeData.scalarType = encoding;
    return typeData;
}

+(void)setObject:(id) object variable:(Ivar) variable withValue:(id) value {

    ALCTypeData *ivarTypeData = [ALCRuntime typeDataForIVar:variable];

    // Wrap the value in an array if it's not an array and ivar is.
    if ([ivarTypeData.objcClass isSubclassOfClass:[NSArray class]] && ![value isKindOfClass:[NSArray class]]) {
        value = @[value];
    }

    if ([value isKindOfClass:ivarTypeData.objcClass]) {
        object_setIvar(object, variable, value);
    } else {
        throwException(@"AlchemicIncorrectType", @"Resolved value of type %2$@ cannot be cast to variable '%1$s' (%3$s)", ivar_getName(variable), NSStringFromClass([value class]), class_getName(ivarTypeData.objcClass));
    }
}

+(void) validateClass:(Class) aClass selector:(SEL)selector {
    if (! [aClass instancesRespondToSelector:selector]) {
        throwException(@"AlchemicSelectorNotFound", @"Failed to find selector %@", [self selectorDescription:aClass selector:selector]);
    }
}

+(NSString *) selectorDescription:(Class) aClass selector:(SEL)selector {
    return str(@"%@[%@ %@]", [aClass respondsToSelector:selector] ? @"+" : @":", NSStringFromClass(aClass), NSStringFromSelector(selector));
}

+(NSString *) propertyDescription:(Class) aClass property:(NSString *)property {
    return str(@"%@.%@", NSStringFromClass(aClass), property);
}

#pragma mark - Scanning

+(void) scanRuntimeWithContext:(id<ALCContext>) context {

    // Use the app bundles and Alchemic framework as the base bundles to search configs classes.
    NSMutableSet<NSBundle *> *appBundles = [[NSSet setWithArray:[NSBundle allBundles]] mutableCopy];
    [appBundles addObject:[NSBundle bundleForClass:[self class]]];

    // Scan the bundles, checking each class.
    NSMutableSet<NSBundle *> *moreBundles = appBundles;
    NSMutableSet<NSBundle *> *scannedBundles;
    while (moreBundles.count > 0) {

        // Add the bundles into the scanned list.
        [NSSet unionSet:moreBundles intoMutableSet:&scannedBundles];

        // San and return a list of new bundles.
        moreBundles = [[ALCRuntimeScanner scanBundles:moreBundles context:context] mutableCopy];

        // Make sure we have not already scanned the new bundles.
        [moreBundles minusSet:scannedBundles];
    }
}

@end

NS_ASSUME_NONNULL_END
