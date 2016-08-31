//
//  ALCRuntime.m
//  Alchemic
//
//  Created by Derek Clarkson on 5/02/2016.
//  Copyright © 2016 Derek Clarkson. All rights reserved.
//
@import StoryTeller;

#import <Alchemic/ALCClassProcessor.h>
#import <Alchemic/ALCConfigClassProcessor.h>
#import <Alchemic/ALCContext.h>
#import <Alchemic/ALCMacros.h>
#import <Alchemic/ALCInternalMacros.h>
#import <Alchemic/ALCModelClassProcessor.h>
#import <Alchemic/ALCAspectClassProcessor.h>
#import <Alchemic/ALCRuntime.h>
#import <Alchemic/ALCValue.h>
#import <Alchemic/NSBundle+Alchemic.h>
#import <Alchemic/ALCException.h>

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
    
    throwException(AlchemicInjectionNotFoundException, @"Cannot find variable/property '%@' in class %s", inj, class_getName(aClass));
}

+(NSArray<ALCType *> *) forClass:(Class) aClass methodArgumentTypes:(SEL) methodSelector {
    
    Method method = class_getClassMethod(aClass, methodSelector);
    if (!method) {
        method = class_getInstanceMethod(aClass, methodSelector);
        if (!method) {
            throwException(AlchemicSelectorNotFoundException, @"Method not found %@", [self forClass:aClass selectorDescription:methodSelector]);
        }
    }
    
    if (method) {
        unsigned int numberArguments = method_getNumberOfArguments(method);
        NSMutableArray *argumentTypes = [[NSMutableArray alloc] initWithCapacity:numberArguments];
        for (unsigned int i = 2; i < numberArguments; i++) {
            char *argumenType = method_copyArgumentType(method, i);
            ALCType *type = [ALCType typeWithEncoding:argumenType];
            [argumentTypes addObject:type];
            free(argumenType);
        }
        return argumentTypes;
    }
    
    throwException(AlchemicSelectorNotFoundException, @"Method not found %@", [self forClass:aClass selectorDescription:methodSelector]);
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

#pragma mark - Validating

+(void) validateClass:(Class) aClass selector:(SEL)selector numberOfArguments:(NSUInteger) nbrArguments {
    
    // Get an instance method.
    NSMethodSignature *sig = [aClass instanceMethodSignatureForSelector:selector];
    if (!sig) {
        sig = [aClass methodSignatureForSelector:selector];
    }
    
    // Not found.
    if (!sig) {
        throwException(AlchemicSelectorNotFoundException, @"Failed to find selector %@", [self forClass:aClass selectorDescription:selector]);
    }
    
    // Incorrect number of arguments. Allow for runtime in arguments.
    if (sig.numberOfArguments - 2 != nbrArguments) {
        throwException(AlchemicIncorrectNumberOfArgumentsException, @"%@ expected %lu arguments, got %lu", [self forClass:aClass selectorDescription:selector],  nbrArguments, (unsigned long) sig.numberOfArguments);
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
