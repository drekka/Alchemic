//
//  ALCRuntime.m
//  Alchemic
//
//  Created by Derek Clarkson on 5/02/2016.
//  Copyright © 2016 Derek Clarkson. All rights reserved.
//

#import "ALCRuntime.h"

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
        @throw [NSException exceptionWithName:@"AlchemicInjectionNotFound"
                                       reason:[NSString stringWithFormat:@"Cannot find variable/property '%@' in class %s", inj, class_getName(aClass)]
                                     userInfo:nil];
    }

    return var;
}

+(nullable Class) classForIVar:(Ivar) ivar {

    // Get the type.
    NSArray *iVarTypes = [self typesForIVar:ivar];
    if (iVarTypes == nil) {
        return nil;
    }

    // Must have some type information returned.
    return iVarTypes[0];
}

#pragma mark - Internal

+(nullable NSArray *) typesForIVar:(Ivar) iVar {

    // Get the type.
    NSString *variableTypeEncoding = [NSString stringWithUTF8String:ivar_getTypeEncoding(iVar)];
    if (![variableTypeEncoding hasPrefix:@"@"]) {
        return nil;
    }

    // Start with a result that indicates an Id. We map Ids as NSObjects.
    NSMutableArray *results = [NSMutableArray arrayWithObject:[NSObject class]];

    // Object type.
    NSArray<NSString *> *defs = [variableTypeEncoding componentsSeparatedByCharactersInSet:__typeEncodingDelimiters];

    // If there is no more than 2 in the array then the dependency is an id.
    // Position 3 will be a class name, positions beyond that will be protocols.
    for (NSUInteger i = 2; i < [defs count]; i ++) {
        if ([defs[i] length] > 0) {
            if (i == 2) {
                // Update the class.
                results[0] = objc_lookUpClass(defs[2].UTF8String);
            } else {
                [results addObject:objc_getProtocol(defs[i].UTF8String)];
            }
        }
    }
    return results;

}


@end

NS_ASSUME_NONNULL_END
