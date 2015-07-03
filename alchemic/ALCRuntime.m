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
#import "NSDictionary+ALCModel.h"
#import "ALCModelClassProcessor.h"
#import "ALCClassWithProtocolClassProcessor.h"
#import "ALCResourceLocator.h"

@implementation ALCRuntime

static Class __protocolClass;

+(void) initialize {
    __protocolClass = objc_getClass("Protocol");
}

#pragma mark - General

+(nonnull const char *) concat:(const char __nonnull *) left to:(const char __nonnull *) right {
    return [NSString stringWithFormat:@"%s%s", left, right].UTF8String;
}

+(SEL) alchemicSelectorForSelector:(SEL) selector {
    const char * prefix = _alchemic_toCharPointer(ALCHEMIC_PREFIX);
    const char * selName = sel_getName(selector);
    const char * newSelectorName = [self concat:prefix to:selName];
    return sel_registerName(newSelectorName);
}

+(BOOL) classIsProtocol:(Class __nonnull) possiblePrototocol {
    return __protocolClass == possiblePrototocol;
}

+(void) injectObject:(id __nonnull) object variable:(Ivar __nonnull) variable withValue:(id __nullable) value {
    object_setIvar(object, variable, value);
}

+(void) validateMatcher:(id __nonnull) object {
    if ([object conformsToProtocol:@protocol(ALCMatcher)]) {
        return;
    }
    @throw [NSException exceptionWithName:@"AlchemicNotAMatcher"
                                   reason:[NSString stringWithFormat:@"Passed matcher %s does not conform to the ALCMatcher protocol", object_getClassName(object)]
                                 userInfo:nil];
}

+(void) validateSelector:(SEL __nonnull) selector withClass:(Class __nonnull) class {
    if (! class_respondsToSelector(class, selector)) {
        @throw [NSException exceptionWithName:@"AlchemicSelectorNotFound"
                                       reason:[NSString stringWithFormat:@"Faciled to find selector %s::%s", class_getName(class), sel_getName(selector)]
                                     userInfo:nil];
    }
}

+(BOOL) class:(Class __nonnull) class isKindOfClass:(Class __nonnull) otherClass {
    Class nextClass = class;
    while (nextClass != nil) {
        if (nextClass == otherClass) {
            return YES;
        }
        nextClass = class_getSuperclass(nextClass);
    }
    return NO;
}

+(nullable Class) iVarClass:(Ivar __nonnull) ivar {
    NSString *variableTypeEncoding = [NSString stringWithUTF8String:ivar_getTypeEncoding(ivar)];
    if ([variableTypeEncoding hasPrefix:@"@"]) {
        NSArray<NSString *> *defs = [variableTypeEncoding componentsSeparatedByCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@"@\",<>"]];
        return [defs[2] length] > 0 ? objc_lookUpClass(defs[2].UTF8String) : [NSObject class];
    } else {
        // Non object variable.
        return nil;
    }
}

+(nonnull NSSet<Protocol *> *) protocolsOnClass:(Class __nonnull) class {
    NSMutableSet<Protocol *> *protocols = [[NSMutableSet<Protocol *> alloc] init];
    unsigned int protocolCount;
    Protocol * __unsafe_unretained *protocolList = class_copyProtocolList(class, &protocolCount);
    if (protocolCount > 0) {
        for (unsigned int i = 0; i < protocolCount; i++) {
            [protocols addObject:protocolList[i]];
        }
        free(protocolList);
    }
    return protocols;
}

+(void) scanRuntimeWithContext:(ALCContext __nonnull *) context {

    ClassMatchesBlock initStrategiesBlock = ^(classMatchesBlockArgs){
        [context addInitStrategy:class];
    };

    ClassMatchesBlock resolverPostProcessorBlock = ^(classMatchesBlockArgs){
        [context addDependencyPostProcessor:[[class alloc] init]];
    };

    ClassMatchesBlock resourceLocatorBlock = ^(classMatchesBlockArgs){
        ALCClassBuilder *classBuilder = [context.model createClassBuilderForClass:class inContext:context];
        classBuilder.value = [[class alloc] init];
    };

    ClassMatchesBlock objectFactoryBlock = ^(classMatchesBlockArgs){
        [context addObjectFactory:[[class alloc] init]];
    };

    NSSet *processors = [NSSet setWithArray:@[
                                              [[ALCModelClassProcessor alloc] init],
                                              [[ALCClassWithProtocolClassProcessor alloc] initWithProtocol:@protocol(ALCInitStrategy)
                                                                                               whenMatches:initStrategiesBlock],
                                              [[ALCClassWithProtocolClassProcessor alloc] initWithProtocol:@protocol(ALCDependencyPostProcessor)
                                                                                               whenMatches:resolverPostProcessorBlock],
                                              [[ALCClassWithProtocolClassProcessor alloc] initWithProtocol:@protocol(ALCResourceLocator)
                                                                                               whenMatches:resourceLocatorBlock],
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

+(nullable Ivar) class:(Class __nonnull) class variableForInjectionPoint:(NSString __nonnull *) inj {

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

    STLog(class, @"   Injection %@ -> variable: %s", inj, ivar_getName(var));
    return var;
}

+(nonnull NSSet<id<ALCMatcher>> *) matchersForClass:(Class __nonnull) class {
    NSMutableSet<id<ALCMatcher>> * matchers = [[NSMutableSet<id<ALCMatcher>> alloc] init];
    [matchers addObject:[ALCClassMatcher matcherWithClass:class]];
    for (Protocol *protocol in [self protocolsOnClass:class]) {
        [matchers addObject:[ALCProtocolMatcher matcherWithProtocol:protocol]];
    }
    return matchers;
}

+(nonnull NSSet<id<ALCMatcher>> *) matchersForIVar:(Ivar __nonnull) variable {

    NSMutableSet<id<ALCMatcher>> * matchers = [[NSMutableSet<id<ALCMatcher>> alloc] init];

    // Get the type.
    NSString *variableTypeEncoding = [NSString stringWithUTF8String:ivar_getTypeEncoding(variable)];
    if ([variableTypeEncoding hasPrefix:@"@"]) {

        // Object type.
        NSArray<NSString *> *defs = [variableTypeEncoding componentsSeparatedByCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@"@\",<>"]];

        // If there is no more than 2 in the array then the dependency is an id.
        for (NSUInteger i = 2; i < [defs count]; i ++) {
            if ([defs[i] length] > 0) {
                if (i == 2) {
                    Class depClass = objc_lookUpClass(defs[2].UTF8String);
                    [matchers addObject:[ALCClassMatcher matcherWithClass:depClass]];
                } else {
                    Protocol *protocol = objc_getProtocol(defs[i].UTF8String);
                    [matchers addObject:[ALCProtocolMatcher matcherWithProtocol:protocol]];
                }
            }
        }

    } else {
        // Non object variable.
    }
    
    return matchers;
}

@end
