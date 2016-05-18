//
//  ALCRuntime.m
//  Alchemic
//
//  Created by Derek Clarkson on 5/02/2016.
//  Copyright © 2016 Derek Clarkson. All rights reserved.
//

#import "ALCClassProcessor.h"
#import "ALCConfigClassProcessor.h"
#import "ALCContext.h"
#import "ALCInternalMacros.h"
#import "ALCModelClassProcessor.h"
#import "ALCResourceLocatorClassProcessor.h"
#import "ALCRuntime.h"
#import "ALCTypeData.h"
#import "NSSet+Alchemic.h"
#import <StoryTeller/StoryTeller.h>
#import "NSBundle+Alchemic.h"

NS_ASSUME_NONNULL_BEGIN

@implementation ALCRuntime

static Class __protocolClass;
static NSCharacterSet *__typeEncodingDelimiters;

+(void) initialize {
    __protocolClass = objc_getClass("Protocol");
    __typeEncodingDelimiters = [NSCharacterSet characterSetWithCharactersInString:@"@\",<>"];
}

#pragma mark - Querying things

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
        throwException(InjectionNotFound, @"Cannot find variable/property '%@' in class %s", inj, class_getName(aClass));
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

#pragma mark - Setting variables

+(void) setObject:(id) object
         variable:(Ivar) variable
        withValue:(id) value {
    
    ALCTypeData *ivarTypeData = [ALCRuntime typeDataForIVar:variable];
    
    id finalValue = [self mapValue:value toType:(Class _Nonnull) ivarTypeData.objcClass];
    
    STLog([object class], @"Injecting %@ with a %@", [ALCRuntime propertyDescription:[object class] variable:variable], [finalValue class]);
    object_setIvar(object, variable, finalValue);
}

+(void) setInvocation:(NSInvocation *) inv
             argIndex:(int) idx
            withValue:(id) value
              ofClass:(Class) valueClass {
    id finalValue = [self mapValue:value toType:(Class _Nonnull) valueClass];
    [inv setArgument:&finalValue atIndex:idx];
}

+(id) mapValue:(id) value toType:(Class) type {
    
    // Wrap the value in an array if it's not alrady in an array.
    if ([type isSubclassOfClass:[NSArray class]]) {
        return [value isKindOfClass:[NSArray class]] ? value : @[value];
    }
    
    // Throw an error if we are dealing with an array value and we have too many results.
    if ([value isKindOfClass:[NSArray class]]) {
        NSArray *values = (NSArray *) value;
        if (values.count != 1) {
            throwException(TooManyValues, @"Target type is not an array and found %lu values", values.count);
        }
        return values[0];
    }
    
    if ([value isKindOfClass:type]) {
        return value;
    }
    
    throwException(TypeMissMatch, @"Value of type %@ cannot be cast to a %@", NSStringFromClass([value class]), NSStringFromClass(type));
}

#pragma mark - Validating

+(void) validateClass:(Class) aClass selector:(SEL)selector arguments:(nullable NSArray<id<ALCDependency>> *) arguments {
    
    // Get an instance method.
    NSMethodSignature *sig = [aClass instanceMethodSignatureForSelector:selector];
    if (!sig) {
        // Or try for a class method.
        sig = [aClass methodSignatureForSelector:selector];
    }
    
    // Not found.
    if (!sig) {
        throwException(SelectorNotFound, @"Failed to find selector %@", [self selectorDescription:aClass selector:selector]);
    }
    
    // Incorrect number of arguments. Allow for runtime in arguments.
    if (sig.numberOfArguments - 2 != (arguments ? arguments.count : 0)) {
        throwException(IncorrectNumberOfArguments, @"%@ expected %lu arguments, got %lu", [self selectorDescription:aClass selector:selector], (unsigned long) sig.numberOfArguments, (unsigned long) arguments.count);
    }
}

#pragma mark - Describing things

+(NSString *) selectorDescription:(Class) aClass selector:(SEL)selector {
    return str(@"%@[%@ %@]", [aClass respondsToSelector:selector] ? @"+" : @"-", NSStringFromClass(aClass), NSStringFromSelector(selector));
}

+(NSString *) propertyDescription:(Class) aClass property:(NSString *)property {
    return str(@"%@.%@", NSStringFromClass(aClass), property);
}

+(NSString *) propertyDescription:(Class) aClass variable:(Ivar) variable {
    return str(@"%@.%s", NSStringFromClass(aClass), ivar_getName(variable));
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
        moreBundles = [[self scanBundles:moreBundles context:context] mutableCopy];
        
        // Make sure we have not already scanned the new bundles.
        [moreBundles minusSet:scannedBundles];
    }
}

+(nullable NSSet<NSBundle *> *) scanBundles:(NSSet<NSBundle *> *) bundles context:(id<ALCContext>) context {
    
    NSArray<id<ALCClassProcessor>> *processors = @[
                                                   [[ALCConfigClassProcessor alloc] init],
                                                   [[ALCModelClassProcessor alloc] init],
                                                   [[ALCResourceLocatorClassProcessor alloc] init]
                                                   ];
    NSMutableSet<NSBundle *> *moreBundles;
    for (NSBundle *bundle in bundles) {
        NSSet<NSBundle *> *addBundles = [bundle scanWithProcessors:processors context:context];
        [NSSet unionSet:addBundles intoMutableSet:&moreBundles];
    }
    return moreBundles;
}

#pragma mark - Executing blocks

+(void) executeSimpleBlock:(nullable ALCSimpleBlock) block {
    if (block) {
        block();
    }
}

+(void) executeCompletion:(nullable ALCObjectCompletion) completion withObject:(id) object {
    if (completion) {
        completion(object);
    }
}


@end

NS_ASSUME_NONNULL_END
