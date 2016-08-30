//
//  ALCRuntime.m
//  Alchemic
//
//  Created by Derek Clarkson on 5/02/2016.
//  Copyright © 2016 Derek Clarkson. All rights reserved.
//
@import StoryTeller;

#import "ALCClassProcessor.h"
#import "ALCConfigClassProcessor.h"
#import "ALCContext.h"
#import "ALCMacros.h"
#import "ALCInternalMacros.h"
#import "ALCModelClassProcessor.h"
#import "ALCResourceLocatorClassProcessor.h"
#import "ALCAspectClassProcessor.h"
#import "ALCRuntime.h"
#import "ALCValue.h"
#import "NSBundle+Alchemic.h"
#import "ALCException.h"

NS_ASSUME_NONNULL_BEGIN

bool AcStrHasPrefix(const char *str, const char *prefix) {
    return strncmp(prefix, str, strlen(prefix)) == 0;
}

@implementation ALCRuntime

static Class __protocolClass;
static NSCharacterSet *__typeEncodingDelimiters;

+(void) initialize {
    __protocolClass = objc_getClass("Protocol");
    __typeEncodingDelimiters = [NSCharacterSet characterSetWithCharactersInString:@"@\",<>"];
}

#pragma mark - Querying things

+(Ivar) forClass:(Class) aClass variableForInjectionPoint:(NSString *) inj {

    // First attempt to get an instance variable with the passed name
    const char * charName = [inj UTF8String];
    Ivar instanceVar = class_getInstanceVariable(aClass, charName);
    if (instanceVar) {
        return instanceVar;
    }

    // Not found, so try for a property based on the passed name.
    // The property's internal variable may have a completely different variable name so we have to dig that out and return it.
    objc_property_t prop = class_getProperty(aClass, charName);
    if (prop) {
        // Return the internal variable.
        const char *propVarName = property_copyAttributeValue(prop, "V"); // This has to be free'd.
        Ivar propertyVar = class_getInstanceVariable(aClass, propVarName);
        free((void *) propVarName);
        return propertyVar;
    }

    throwException(InjectionNotFound, @"Cannot find variable/property '%@' in class %s", inj, class_getName(aClass));
}

+(NSArray<ALCType *> *) forClass:(Class) aClass methodArgumentTypes:(SEL) methodSelector {

    Method method = class_getClassMethod(aClass, methodSelector);
    if (!method) {
        method = class_getInstanceMethod(aClass, methodSelector);
        if (!method) {
            unsigned int numberArguments = method_getNumberOfArguments(method);
            NSMutableArray *argumentTypes = [[NSMutableArray alloc] initWithCapacity:numberArguments];
            for (unsigned int i = 0; i < numberArguments; i++) {
                char *argumenType = method_copyArgumentType(method, i);
                ALCType *type = [ALCType typeWithEncoding:argumenType];
                [argumentTypes addObject:type];
                free(argumenType);
            }
            return argumentTypes;
        }
    }

    throwException(SelectorNotFound, @"Method not found %@", [self forClass:aClass selectorDescription:methodSelector]);
}

+(NSArray<NSString*> *) writeablePropertiesForClass:(Class) aClass {
    unsigned int count = 0;
    objc_property_t *props = class_copyPropertyList(aClass, &count);
    NSMutableArray *results = [[NSMutableArray alloc] initWithCapacity:count];
    for(unsigned int i = 0;i < count;i++) {
        
        // Find out if the property is a readonly. We only want writables.
        objc_property_t prop = props[i];
        char *readonlyChar = property_copyAttributeValue(prop, "R");
        BOOL readonly = readonlyChar != NULL;
        free(readonlyChar);
        if (readonly) {
            continue;
        }
        
        NSString *propName = [NSString stringWithUTF8String:property_getName(prop)];
        [results addObject:propName];
    }
    free(props);
    return results;
}

#pragma mark - Setting variables

+(nullable id) mapValue:(nullable id) value
              allowNils:(BOOL) allowNil
                   type:(Class) type
                  error:(NSError * __autoreleasing _Nullable *) error {

    // If the passed value is nil or an empty array.
    if (!value) {
        if (!allowNil) {
            setError(@"Nil value encountered where a value was expected")
        }
        return nil;
    }

    // If the target value is an array wrap up the value and return.
    if ([type isSubclassOfClass:[NSArray class]]) {
        return [value isKindOfClass:[NSArray class]] ? value : @[value];
    }

    // Target is not an array

    // Throw an error if the source value is an array and we have too many or too few results.
    id finalValue = value;
    if ([finalValue isKindOfClass:[NSArray class]]) {
        NSArray *values = (NSArray *) finalValue;
        if (values.count == 0 && allowNil) {
            return nil;
        } else if (values.count != 1) {
            setError(@"Expected 1 value, got %lu", (unsigned long) values.count);
            return nil;
        }
        finalValue = values[0];
    }

    if ([finalValue isKindOfClass:type]) {
        return finalValue;
    }

    setError(@"Value of type %@ cannot be cast to a %@", NSStringFromClass([finalValue class]), NSStringFromClass(type));
    return nil;
}

#pragma mark - Validating

+(void) validateClass:(Class) aClass selector:(SEL)selector numberOfArguments:(NSUInteger) nbrArguments {

    // Get an instance method.
    NSMethodSignature *sig = [aClass instanceMethodSignatureForSelector:selector];
    if (!sig) {
        sig = [aClass methodSignatureForSelector:selector];
    }

    // Not found.
    if (!sig) {
        throwException(SelectorNotFound, @"Failed to find selector %@", [self forClass:aClass selectorDescription:selector]);
    }

    // Incorrect number of arguments. Allow for runtime in arguments.
    if (sig.numberOfArguments - 2 != nbrArguments) {
        throwException(IncorrectNumberOfArguments, @"%@ expected %lu arguments, got %lu", [self forClass:aClass selectorDescription:selector],  nbrArguments, (unsigned long) sig.numberOfArguments);
    }
}

#pragma mark - Describing things

+(NSString *) forClass:(Class) aClass selectorDescription:(SEL)selector {
    return [self forClass:aClass selectorDescription:selector static:[aClass respondsToSelector:selector]];
}

+(NSString *) forClass:(Class) aClass propertyDescription:(NSString *)property {
    return str(@"%@.%@", NSStringFromClass(aClass), property);
}

+(NSString *) forClass:(Class) aClass variableDescription:(Ivar) variable {
    return str(@"%@.%s", NSStringFromClass(aClass), ivar_getName(variable));
}

+(NSString *) forClass:(Class) aClass selectorDescription:(SEL)selector static:(BOOL) isStatic {
    return str(@"%@[%@ %@]", isStatic ? @"+" : @"-", NSStringFromClass(aClass), NSStringFromSelector(selector));
}

#pragma mark - Scanning

+(void) scanRuntimeWithContext:(id<ALCContext>) context {

    // Get a list of all the scannable bundles.
    NSSet<NSBundle *> *appBundles = [NSBundle scannableBundles];

    // Scan the bundles, checking each class in each one.
    NSArray<id<ALCClassProcessor>> *processors = @[
                                                   [[ALCConfigClassProcessor alloc] init],
                                                   [[ALCModelClassProcessor alloc] init],
                                                   [[ALCResourceLocatorClassProcessor alloc] init],
                                                   [[ALCAspectClassProcessor alloc] init]
                                                   ];
    [appBundles enumerateObjectsUsingBlock:^(NSBundle *bundle, BOOL *stop) {
        [bundle scanWithProcessors:processors context:context];
    }];
}

#pragma mark - Executing blocks

+(void) executeSimpleBlock:(nullable ALCSimpleBlock) block {
    if (block) {
        block();
    }
}

+(void) executeBlock:(nullable ALCBlockWithObject) block withObject:(nullable id) object {
    if (object && block) {
        block(object);
    }
}

@end

NS_ASSUME_NONNULL_END
