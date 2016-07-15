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
#import <Alchemic/ALCResourceLocatorClassProcessor.h>
#import <Alchemic/ALCRuntime.h>
#import <Alchemic/ALCTypeData.h>
#import <Alchemic/NSSet+Alchemic.h>
#import <Alchemic/NSBundle+Alchemic.h>
#import <Alchemic/ALCException.h>

NS_ASSUME_NONNULL_BEGIN

bool strHasPrefix(const char *str, const char *prefix) {
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

+(Ivar) class:(Class) aClass variableForInjectionPoint:(NSString *) inj {
    
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

+(ALCTypeData *) typeDataForIVar:(Ivar) iVar {
    return [self typeDataForEncoding:ivar_getTypeEncoding(iVar)];
}

+(ALCTypeData *) typeDataForEncoding:(const char *) encoding {
    
    // Get the type.
    ALCTypeData *typeData = [[ALCTypeData alloc] init];
    if (strHasPrefix(encoding, "@")) {
        
        // Start with a result that indicates an Id. We map Ids as NSObjects.
        typeData.objcClass = [NSObject class];
        
        // Object type.
        
        NSArray<NSString *> *defs = [[NSString stringWithUTF8String:encoding] componentsSeparatedByCharactersInSet:__typeEncodingDelimiters];
        
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
    
    STLog([object class], @"Injecting %@ with a %@", [ALCRuntime class:[object class] variableDescription:variable], [finalValue class]);
    object_setIvar(object, variable, finalValue);
}

+(void) setInvocation:(NSInvocation *) inv
             argIndex:(int) idx
            withValue:(id) value
              ofClass:(Class) valueClass {
    id finalValue = [self mapValue:value toType:(Class _Nonnull) valueClass];
    [inv setArgument:&finalValue atIndex:idx + 2];
}

+(id) mapValue:(id) value toType:(Class) type {
    
    // Wrap the value in an array if it's not alrady in an array.
    if ([type isSubclassOfClass:[NSArray class]]) {
        return [value isKindOfClass:[NSArray class]] ? value : @[value];
    }
    
    // Throw an error if we are dealing with an array value and we have too many results.
    id finalValue = value;
    if ([finalValue isKindOfClass:[NSArray class]]) {
        NSArray *values = (NSArray *) finalValue;
        if (values.count != 1) {
            throwException(TooManyValues, @"Target type is not an array and found %lu values", (unsigned long) values.count);
        }
        finalValue = values[0];
    }
    
    if ([finalValue isKindOfClass:type]) {
        return finalValue;
    }
    
    throwException(TypeMissMatch, @"Value of type %@ cannot be cast to a %@", NSStringFromClass([finalValue class]), NSStringFromClass(type));
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
        throwException(SelectorNotFound, @"Failed to find selector %@", [self class:aClass selectorDescription:selector]);
    }
    
    // Incorrect number of arguments. Allow for runtime in arguments.
    if (sig.numberOfArguments - 2 != (arguments ? arguments.count : 0)) {
        throwException(IncorrectNumberOfArguments, @"%@ expected %lu arguments, got %lu", [self class:aClass selectorDescription:selector], (unsigned long) sig.numberOfArguments, (unsigned long) arguments.count);
    }
}

#pragma mark - Describing things

+(NSString *) class:(Class) aClass selectorDescription:(SEL)selector {
    return str(@"%@[%@ %@]", [aClass respondsToSelector:selector] ? @"+" : @"-", NSStringFromClass(aClass), NSStringFromSelector(selector));
}

+(NSString *) class:(Class) aClass propertyDescription:(NSString *)property {
    return str(@"%@.%@", NSStringFromClass(aClass), property);
}

+(NSString *) class:(Class) aClass variableDescription:(Ivar) variable {
    return str(@"%@.%s", NSStringFromClass(aClass), ivar_getName(variable));
}

#pragma mark - Scanning

+(void) scanRuntimeWithContext:(id<ALCContext>) context {
    
    // Start with the main app bundles.
    NSMutableArray<NSBundle *> *appBundles = [[NSBundle allBundles] mutableCopy];

    // Get resource ids of the framework directories from each bundle
    NSMutableSet *mainBundleResourceIds = [[NSMutableSet alloc] init];
    [appBundles enumerateObjectsUsingBlock:^(NSBundle *bundle, NSUInteger idx, BOOL *stop) {
        id bundleFrameworksDirId = nil;
        [bundle.privateFrameworksURL getResourceValue:&bundleFrameworksDirId forKey:NSURLFileResourceIdentifierKey error:nil];
        if (bundleFrameworksDirId) {
            [mainBundleResourceIds addObject:bundleFrameworksDirId];
        }
    }];

    // Loop through the app's frameworks and add those that are in the app bundle's frameworks directories.
    [[NSBundle allFrameworks] enumerateObjectsUsingBlock:^(NSBundle *framework, NSUInteger idx, BOOL *stop) {

        NSURL *frameworkDirectoryURL = nil;
        [framework.bundleURL getResourceValue:&frameworkDirectoryURL forKey:NSURLParentDirectoryURLKey error:nil];

        id frameworkDirectoryId = nil;
        [frameworkDirectoryURL getResourceValue:&frameworkDirectoryId forKey:NSURLFileResourceIdentifierKey error:nil];
        
        if ([mainBundleResourceIds containsObject:frameworkDirectoryId]) {
            [appBundles addObject:framework];
        }
    }];
    
    // Scan the bundles, checking each class.
    NSArray<id<ALCClassProcessor>> *processors = @[
                                                   [[ALCConfigClassProcessor alloc] init],
                                                   [[ALCModelClassProcessor alloc] init],
                                                   [[ALCResourceLocatorClassProcessor alloc] init]
                                                   ];
    [appBundles enumerateObjectsUsingBlock:^(NSBundle *bundle, NSUInteger idx, BOOL *stop) {
        [bundle scanWithProcessors:processors context:context];
    }];
}

#pragma mark - Executing blocks

+(void) executeSimpleBlock:(nullable ALCSimpleBlock) block {
    if (block) {
        block();
    }
}

+(void) executeBlock:(nullable ALCBlockWithObject) block withObject:(id) object {
    if (block) {
        block(object);
    }
}

@end

NS_ASSUME_NONNULL_END
