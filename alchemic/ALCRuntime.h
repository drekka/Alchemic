//
//  ALCRuntime.h
//  Alchemic
//
//  Created by Derek Clarkson on 5/02/2016.
//  Copyright © 2016 Derek Clarkson. All rights reserved.
//

@import Foundation;
@import ObjectiveC;

#import <Alchemic/ALCTypeDefs.h>

@class ALCValue;
@class ALCInstantiation;
@protocol ALCContext;
@protocol ALCDependency;
@class ALCType;

NS_ASSUME_NONNULL_BEGIN

/**
 Fast has prefix function for use on c strings.

 Used when we are dealing with char *'s and don't want to convert to NSString * instances.

 @param prefix The prefix we are looking for.
 @param str    The string to test.

 @return true if str begins with prefix, false otherwise.
 */
bool AcStrHasPrefix(const char *str, const char *prefix);

/**
 Methods which provide access to the Objective-C runtime.
 */
@interface ALCRuntime : NSObject

#pragma mark - Querying the runtime

/// @name Examining the runtime

/**
 Returns the ivar behind the name of a variable or property.

 If the passed string is a property then the property is examined for the actual variable behind it. THis variable can be a completely different name to the property name. Internal variables can be accessed either with or without a '_' prefix.

 @param aClass The class to examine for the variable.
 @param inj    The name of the variable to locate.

 @return An ivar representing the variable.
 */
+(Ivar) forClass:(Class) aClass variableForInjectionPoint:(NSString *) inj;

+(NSArray<ALCType *> *) forClass:(Class) aClass methodArgumentTypes:(SEL) methodSelector;

/**
 Returns a list of all the writable properties in the specified class. 
 
 @discussion Only includes properties defined in that class.
 
 @param aClass The class to examine for the variable.
 @return a list of the available properties.
 */
+(NSArray<NSString*> *) writeablePropertiesForClass:(Class) aClass;

#pragma mark - Seting variables

/// @name Setting values

/**
 Maps a value to a type.

 This basically means that the value is assessed to see if it can be converted to the target type. This also takes into account such things as the target being an array and possibly needing to wrap the passed value in an array.

 @param value The value to check.
 @param type  The type it needs to be.
 @param allowNil If YES, allows nil values to be passed and set. Otherwise throws an error if nil values or empty arrays are encountered when there should be values.
 @param error a pointer to a NSError vaiable which will be populated if an error occurs.

 @return A new value matching the passed type.
 */
+(nullable id) mapValue:(nullable id) value allowNils:(BOOL) allowNil type:(Class) type error:(NSError * _Nullable *) error;

#pragma mark - Validating

/// @name Validating

/**
 Validates that the passed selector occurs on the passed class and has a correct set of arguments stored in the macro processor.

 @param aClass The class to be used to check the selector again.
 @param selector The selector to check.
 @param nbrArguments The expected number of arguments.
 @exception ALCException If there is a problem.
 */
+(void) validateClass:(Class) aClass selector:(SEL)selector numberOfArguments:(NSUInteger) nbrArguments;

#pragma mark - Describing things

/// @name Describing objects

/**
 Returns a NSString description of a class and selector.

 @discussion This internally works out whether the method is a class or instance method and then calls forClass:selectorDescription:static:
 
 @param aClass   The class.
 @param selector The selector to describe.

 @return A string which describes the class and selector.
 */
+(NSString *) forClass:(Class) aClass selectorDescription:(SEL)selector;

/**
 Returns a NSString description of a class and selector.
 
 @param aClass   The class.
 @param selector The selector to describe.
 @param isStatic YES if the method is a class method.
 
 @return A string which describes the class and selector.
 */
+(NSString *) forClass:(Class) aClass selectorDescription:(SEL)selector static:(BOOL) isStatic;

/**
 Returns a NSString description of a class and property.

 @param aClass   The class.
 @param property The property.

 @return A string which describes the class and property.
 */
+(NSString *) forClass:(Class) aClass propertyDescription:(NSString *)property;

/**
 Returns a NSString description of a class and ivar.

 @param aClass   The class.
 @param variable The ivar.

 @return A string which describes the class and ivar.
 */
+(NSString *) forClass:(Class) aClass variableDescription:(Ivar) variable;

#pragma mark - Scanning

/// @name Other tasks

/**
 Scans the runtime looking for classes which define Alchemic model factories.

 The runtime is defined as all bundles for the current app, plsu any further bundles defined by classes which conform to the ALCConfig protocol. All the classes are read from each bundle and scanned for methods which Alchemic recognises. When it finds a method, appropriate model factories are created and setup according to what the method is.

 @param context The default context.
 */
+(void) scanRuntimeWithContext:(id<ALCContext>) context;

#pragma mark - Executing blocks

/**
 Executes a ALCSimpleBlock if it's not null.

 This is mostly a conveniant method designed to remove boilderplate around block executions.

 @param block The block to be executed.
 */
+(void) executeSimpleBlock:(nullable ALCSimpleBlock) block;

/**
 Executes a passed block if it's not null.

 This is mostly a conveniant method designed to remove boilderplate around block executions. Only if both the block and the object are present will the block be called.

 @param block The block to be executed.
 @param object     An object to be passed to the completion.
 */
+(void) executeBlock:(nullable ALCBlockWithObject) block withObject:(nullable id) object;

@end

NS_ASSUME_NONNULL_END
