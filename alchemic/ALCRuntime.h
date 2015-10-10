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

/**
 This class provides a variety of functions for accessing the Objective-C runtime and getting information.
 */
@interface ALCRuntime : NSObject

#pragma mark - Checking and Querying

/// @name Querying

/**
 Queries the type of the object to see if it is a class.
 
 @param possibleClass An object that may or may not be a Class.
 @return YES if possibleClass is a class.
*/
+(BOOL) objectIsAClass:(id) possibleClass;

/**
 Queries the type of the object to see if it is a protocol.

 @param possibleProtocol An object that may or may not be a Protocol *.
 @return YES if possibleClass is a protocol.
 */
+(BOOL) objectIsAProtocol:(id) possibleProtocol;

/**
 Queries a class to obtain a list of the protocols it conforms to.
 
 @param aClass The class we are going to query.
 @return a NSSet containing a list of Protocol pointers.
 */
+(NSSet<Protocol *> *) aClassProtocols:(Class) aClass;

/**
 Queries an Ivar to get it's class.
 
 @param ivar The ivar we are interested in.
 @return The Class of the ivar or nil if the ivar not an Objective-C object type.
 */
+(nullable Class) iVarClass:(Ivar) ivar;

/**
 Scans a class to find the actual variable used.
 @discussion The passed injection point is used to locate one of three possibilities.
 Either a matching instance variable with the same name, a class variable of the same name or a property whose variable uses the name. When looking for the variable behind a property, a '_' is prefixed.

 @param aClass the class to look at.
 @param inj   The name of the variable.

 @return the Ivar for the variable.
 @throw an exception if no matching variable is found.
 */
+(nullable Ivar) aClass:(Class) aClass variableForInjectionPoint:(NSString *) inj;

/**
 Returns a Alchemic description of a class. 
 
 @discussion This is formatted as [Class]<protocol>...

 @param aClass The class to get a description of.

 @return The NSString description.
 */
+(NSString *) aClassDescription:(Class) aClass;

#pragma mark - General

/// @name Validation

/**
 Validates that the passed selector occurs on the passed class and has a correct set of arguments stored in the macro processor.

 @param aClass The class to be used to check the selector again.
 @param selector The selector to check.
 @exception NSException If there is a problem.
 */
+(void) validateClass:(Class) aClass selector:(SEL)selector;

#pragma mark - Getting qualifiers

/// @name Search expressions

/**
 Builds a set of search expressions which match a specific class.
 
 @discussion The set of expressions can then be used to find all occurances of this class in the model.
 
 @param aClass The class to build the set from.
 @return A NSSet of ALCModelSearchExpression objects derived from aClass.
 */
+(NSSet<id<ALCModelSearchExpression>> *) searchExpressionsForClass:(Class) aClass;

/**
 Builds a set of search expressions which match a specific variable.

 @discussion The set of expressions can then be used to find all occurances of objects that can be injected into the variable.

 @param variable The variable whose type will be used to build the set of expressions from.
 @return A NSSet of ALCModelSearchExpression objects derived from the variable's type.
 */
+(NSSet<id<ALCModelSearchExpression>> *) searchExpressionsForVariable:(Ivar) variable;

#pragma mark - Runtime scanning

/**
 Scans the classes in the runtime, looking for Alchemic signatures and declarations.
 
 @discussion This is the method that does the grunt work of registering objects in the model. It scans all the relevant app bundles and frameworks, plus those declared in ALCConfig classes. When it finds a class with Alchemic methods in it, it creates an instance of ALCBuilder and adds it to the model before call the methods to execute the registrations.
 
 @param context The ALCContext that is being loaded with information.
 @param runtimeScanners A NSSet of ALCRuntimeScanner instances which perform the job of interpreting what they find in the classes. Each class found with Alchemic methods in it is passed to each scanner in turn.
 */
+(void) scanRuntimeWithContext:(ALCContext *) context runtimeScanners:(NSSet<ALCRuntimeScanner *> *) runtimeScanners;

@end

NS_ASSUME_NONNULL_END
