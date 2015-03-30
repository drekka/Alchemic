//
//  ALCRuntimeClassDecorations.m
//  alchemic
//
//  Created by Derek Clarkson on 29/03/2015.
//  Copyright (c) 2015 Derek Clarkson. All rights reserved.
//

#import "ALCRuntimeClassDecorations.h"
#import "ALCLogger.h"
#import "ALCRuntime.h"
#import "ALCDependency.h"
#import "NSDictionary+ALCModel.h"

#import <objc/runtime.h>
#import <objc/message.h>

@implementation ALCRuntimeClassDecorations

static SEL injectDependenciesSelector;
static SEL addInjectionSelector;
static SEL resolveDependenciesSelector;

static const char * dependenciesProperty = "_alchemic_dependencies";

#pragma mark - Decorating the class

+(BOOL) classIsDecorated:(Class) class {
    return [class respondsToSelector:injectDependenciesSelector];
}

+(void) decorateClass:(Class) class {
    
    logRuntime(@"Decorating class %s with Alchemic methods", class_getName(class));
    
    // Store selectors
    if (injectDependenciesSelector == NULL) {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wundeclared-selector"
        injectDependenciesSelector = @selector(_alchemic_injectUsingDependencyInjectors:);
        addInjectionSelector = @selector(_alchemic_addinjection:withQualifier:);
        resolveDependenciesSelector = @selector(_alchemic_resolveDependenciesWithModel:dependencyResolvers:);
#pragma clang diagnostic pop
    }
    
    class_addMethod(class, injectDependenciesSelector, (IMP) _alchemic_injectDependenciesWithInjectors, "v@:@");

    // Class methods are added by adding to the meta class.
    Class metaClass = object_getClass(class);
    class_addMethod(metaClass, addInjectionSelector, (IMP) _alchemic_addInjectionWithQualifier, "v@:@@");
    class_addMethod(metaClass, resolveDependenciesSelector, (IMP) _alchemic_resolveDependenciesWithModel, "v@:@@");

    logRuntime(@"Adding dependency storage to %s", class_getName(self));
    NSMutableArray *dependencies = [[NSMutableArray alloc] init];
    objc_setAssociatedObject(class, dependenciesProperty, dependencies, OBJC_ASSOCIATION_RETAIN_NONATOMIC);

}

#pragma mark - Registering injections

+(void) addInjectionToClass:(Class) class injection:(NSString *) inj qualifier:(NSString *) qualifier {
    ((void (*)(id, SEL, NSString *, NSString *))objc_msgSend)(class, addInjectionSelector, inj, qualifier);
}

void _alchemic_addInjectionWithQualifier(id self, SEL cmd, NSString *inj, NSString *qualifier) {
    
    // Create the dependency info to be store.
    Ivar variable = [ALCRuntime variableInClass:self forInjectionPoint:[inj UTF8String]];
    ALCDependency *dependency = [[ALCDependency alloc] initWithVariable:variable qualifier:qualifier];
    logRegistration(@"Registering: '%@' (%s::%s)->%@", qualifier, class_getName(self), ivar_getName(variable), dependency.variableTypeEncoding);
    
    // Get the storage from the class.
    NSMutableArray *dependencies = objc_getAssociatedObject(self, dependenciesProperty);
    
    // Store the new dependency.
    [dependencies addObject:dependency];
    
}

#pragma mark - Dependency resolving

+(void) resolveDependenciesInClass:(Class) class withModel:(NSDictionary *) model dependencyResolvers:(NSArray *) dependencyResolvers {
    ((void (*)(id, SEL, NSDictionary *, NSArray *))objc_msgSend)(class, resolveDependenciesSelector, model, dependencyResolvers);
}

void _alchemic_resolveDependenciesWithModel(id self, SEL cmd, NSDictionary * model, NSArray * dependencyResolvers) {
    NSArray *dependencies = objc_getAssociatedObject(self, dependenciesProperty);
    for (ALCDependency *dependency in dependencies) {
        
        NSDictionary *candidates = [model objectDescriptionsForClass:dependency.variableClass
                                                           protocols:dependency.variableProtocols
                                                           qualifier:dependency.variableQualifier
                                                      usingResolvers:dependencyResolvers];
        if (candidates == nil) {
            @throw [NSException exceptionWithName:@"AlchemicDependencyNotFound"
                                           reason:[NSString stringWithFormat:@"Unable to resolve '%@' %s<%@>", dependency.variableQualifier, class_getName(dependency.variableClass), [dependency.variableProtocols componentsJoinedByString:@","]]
                                         userInfo:nil];
        }
        
        dependency.candidateObjectDescriptions = candidates;
        logDependencyResolving(@"Resolved dependency");
        
    }
}

#pragma mark - Injection

+(void) injectDependenciesInto:(id) object usingDependencyInjectors:(NSArray *) dependencyInjectors {
    ((void (*)(id, SEL, NSArray *))objc_msgSend)(object, injectDependenciesSelector, dependencyInjectors);
}

// Note this is an instance method. Unlike the ones above which are class methods.
void _alchemic_injectDependenciesWithInjectors(id self, SEL cmd, NSArray * dependencyInjectors) {
    NSArray *dependencies = objc_getAssociatedObject([self class], dependenciesProperty);
    for (ALCDependency *dependency in dependencies) {
        [dependency injectObject:self usingInjectors:dependencyInjectors];
    }
}

@end
