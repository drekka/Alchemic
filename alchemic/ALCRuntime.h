//
//  AlchemicRuntime.h
//  alchemic
//
//  Created by Derek Clarkson on 11/02/2015.
//  Copyright (c) 2015 Derek Clarkson. All rights reserved.
//

@import Foundation;
@import ObjectiveC;

@class ALCRuntimeScanner;
@class ALCContext;
@class ALCQualifier;

@interface ALCRuntime : NSObject

#pragma mark - Checking and Querying

+(BOOL) objectIsAClass:(id __nonnull) possibleClass;

+(BOOL) objectIsAProtocol:(id __nonnull) possiblePrototocol;

+(nonnull NSSet<Protocol *> *) aClassProtocols:(Class __nonnull) aClass;

+(nullable Class) iVarClass:(Ivar __nonnull) ivar;

/**
 Scans a class to find the actual variable used.
 @discussion The passed injection point is used to locate one of three possibilities.
 Either a matching instance variable with the same name, a class variable of the same name or a property whose variable uses the name. When looking for the variable behind a property, a '_' is prefixed.

 @param class the class to look at.
 @param inj   The name of the variable.

 @return the Ivar for the variable.
 @throw an exception if no matching variable is found.
 */
+(nullable Ivar) aClass:(Class __nonnull) aClass variableForInjectionPoint:(NSString __nonnull *) inj;

#pragma mark - General

+(nonnull SEL) alchemicSelectorForSelector:(SEL __nonnull) selector;

+(void) object:(id __nonnull) object injectVariable:(Ivar __nonnull) variable withValue:(id __nullable) value;

#pragma mark - Getting qualifiers

+(nonnull NSSet<ALCQualifier *> *) qualifiersForClass:(Class __nonnull) class;

+(nonnull NSSet<ALCQualifier *> *) qualifiersForVariable:(Ivar __nonnull) variable;

#pragma mark - Runtime scanning

/**
 Scans the classes in the runtime, looking for Alchemic signatures and declarations.
 @discussion Once found, the block is called to finish the registration of the class.
 */
+(void) scanRuntimeWithContext:(ALCContext __nonnull *) context runtimeScanners:(NSSet<ALCRuntimeScanner *> __nonnull *) runtimeScanners;

@end
