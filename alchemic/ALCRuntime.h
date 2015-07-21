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
@protocol ALCModelSearchExpression;

NS_ASSUME_NONNULL_BEGIN

@interface ALCRuntime : NSObject

#pragma mark - Checking and Querying

+(BOOL) objectIsAClass:(id) possibleClass;

+(BOOL) objectIsAProtocol:(id) possiblePrototocol;

+(NSSet<Protocol *> *) aClassProtocols:(Class) aClass;

+(nullable Class) iVarClass:(Ivar) ivar;

/**
 Scans a class to find the actual variable used.
 @discussion The passed injection point is used to locate one of three possibilities.
 Either a matching instance variable with the same name, a class variable of the same name or a property whose variable uses the name. When looking for the variable behind a property, a '_' is prefixed.

 @param class the class to look at.
 @param inj   The name of the variable.

 @return the Ivar for the variable.
 @throw an exception if no matching variable is found.
 */
+(nullable Ivar) aClass:(Class) aClass variableForInjectionPoint:(NSString *) inj;

#pragma mark - General

+(SEL) alchemicSelectorForSelector:(SEL) selector;

+(void) object:(id) object injectVariable:(Ivar) variable withValue:(id) value;

#pragma mark - Getting qualifiers

+(NSSet<id<ALCModelSearchExpression>> *) searchExpressionsForClass:(Class) class;

+(NSSet<id<ALCModelSearchExpression>> *) searchExpressionsForVariable:(Ivar) variable;

#pragma mark - Runtime scanning

/**
 Scans the classes in the runtime, looking for Alchemic signatures and declarations.
 @discussion Once found, the block is called to finish the registration of the class.
 */
+(void) scanRuntimeWithContext:(ALCContext *) context runtimeScanners:(NSSet<ALCRuntimeScanner *> *) runtimeScanners;

+(void) wrapClass:(Class) destClass initializer:(SEL) initializer
		  withClass:(Class) wrapperClass wrapper:(SEL) wrapperSel;

@end

NS_ASSUME_NONNULL_END
