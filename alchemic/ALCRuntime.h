//
//  AlchemicRuntime.h
//  alchemic
//
//  Created by Derek Clarkson on 11/02/2015.
//  Copyright (c) 2015 Derek Clarkson. All rights reserved.
//

@import Foundation;
#import <objc/runtime.h>

@interface ALCRuntime : NSObject

#pragma mark - General

+(BOOL) class:(Class) child extends:(Class) parent;

+(Ivar) class:(Class) class withName:(NSString *) name;

#pragma mark - Alchemic

/**
 Scans the classes in the runtime, looking for Alchemic signatures and declarations.
 @discussion Once found, the method is called to register the class and variable.
 */
+(void) scanForMacros;

+(BOOL) isClassDecorated:(Class) class;

+(void) decorateClass:(Class) class;

/**
 Scans a class to find the actual variable used.
 @discussion The passed injection point is used to locate one of three possibilities.
 Either a matching instance variable with the same name, a class variable of the same name or a property whose variable uses the name. When looking for the variable behind a property, a '_' is prefixed.
 
 @param class the class to look at.
 @param inj   The name of the variable.
 
 @return the Ivar for the variable.
 @throw an exception if no matching variable is found.
 */
+(Ivar) class:(Class) class variableForInjectionPoint:(NSString *) inj;

+(void) class:(Class) class addInjection:(NSString *) inj withQualifiers:(NSArray *) qualifiers;

+(void) class:(Class) class resolveDependenciesWithResolvers:(NSArray *) dependencyResolvers;

+(void) object:(id) object injectUsingDependencyInjectors:(NSArray *) dependencyInjectors;

@end
