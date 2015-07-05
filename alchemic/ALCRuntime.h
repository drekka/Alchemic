//
//  AlchemicRuntime.h
//  alchemic
//
//  Created by Derek Clarkson on 11/02/2015.
//  Copyright (c) 2015 Derek Clarkson. All rights reserved.
//

@import Foundation;
@import ObjectiveC;

#import <Alchemic/Alchemic.h>

@interface ALCRuntime : NSObject

#pragma mark - General

+(nonnull SEL) alchemicSelectorForSelector:(SEL __nonnull) selector;

+(BOOL) classIsProtocol:(Class __nonnull) possiblePrototocol;

+(void) validateSelector:(SEL __nonnull) selector withClass:(Class __nonnull) class;

+(void) injectObject:(id __nonnull) object variable:(Ivar __nonnull) variable withValue:(id __nullable) value;

+(BOOL) class:(Class __nonnull) class isKindOfClass:(Class __nonnull) otherClass;

+(BOOL) class:(Class __nonnull) class conformsToProtocol:(Protocol __nonnull *) protocol;

+(nonnull NSSet<Protocol *> *) protocolsOnClass:(Class __nonnull) class;

/**
 Scans a class to find the actual variable used.
 @discussion The passed injection point is used to locate one of three possibilities.
 Either a matching instance variable with the same name, a class variable of the same name or a property whose variable uses the name. When looking for the variable behind a property, a '_' is prefixed.
 
 @param class the class to look at.
 @param inj   The name of the variable.
 
 @return the Ivar for the variable.
 @throw an exception if no matching variable is found.
 */
+(nullable Ivar) class:(Class __nonnull) class variableForInjectionPoint:(NSString __nonnull *) inj;

+(nullable Class) classForIVar:(Ivar __nonnull) ivar;

#pragma mark - Matchers

+(nonnull NSSet<ALCQualifier *> *) qualifiersForClass:(Class __nonnull) class;

+(nonnull NSSet<ALCQualifier *> *) qualifiersForVariable:(Ivar __nonnull) variable;

#pragma mark - Runtime scanning

/**
 Scans the classes in the runtime, looking for Alchemic signatures and declarations.
 @discussion Once found, the block is called to finish the registration of the class.
 */
+(void) scanRuntimeWithContext:(ALCContext __nonnull *) context;

@end
