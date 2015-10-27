//
//  AlchemicContext.h
//  alchemic
//
//  Created by Derek Clarkson on 15/02/2015.
//  Copyright (c) 2015 Derek Clarkson. All rights reserved.
//

@import Foundation;
@import ObjectiveC;

@protocol ALCValueResolver;
@protocol ALCModelSearchExpression;
@class ALCBuilder;
@protocol ALCMacro;
@protocol ALCSourceMacro;
@class ALCBuilder;

NS_ASSUME_NONNULL_BEGIN

/**
 *  Simple block definition.
 */
typedef void (^AcSimpleBlock) (void);

/**
 *  Name of a notification sent after Alchemic has finished loading all singletons and performed all relevant injections.
 */
extern NSString * const AlchemicFinishedLoading;

/**
 Block used when processing a set of ACLBuilders.
 */
#define ProcessBuiderBlockArgs NSSet<ALCBuilder *> *builders
typedef void (^ProcessBuilderBlock)(ProcessBuiderBlockArgs);

/**
 An Alchemic context.

 @discussion Alchemic makes use of an instance of this class to provide the central storage for the class model provided by an ALCModel instance. All incoming requests to regsister classes, injections, methods,e tc and to obtain objects are routed through here.
 */
@interface ALCContext : NSObject

#pragma mark - Registration

/**
 Creates an ALCBuilder instance for the passed class and returns it.

 @discussion Called from the runtime scanner whenever it detects a class with Alchemic methods present.

 @param aClass The class that needs a ALCBuilder.

 @return An instance of ALCBuilder setup for the passed class.
 */
-(ALCBuilder *) registerBuilderForClass:(Class) aClass;

/**
 Sets properties on a ALCBuilder.

 @param classBuilder The class builder whose properties are to be set.
 @param ... one or more macros which define the properties.
 */
-(void) registerClassBuilder:(ALCBuilder *) classBuilder, ... NS_REQUIRES_NIL_TERMINATION;

/**
 Sets properties on an ALCBuilder

 @param classBuilder The class builde to configure.
 @param properties A NSArray of id<ALCMacro> instances defining the configuration.
 */
-(void) registerClassBuilder:(ALCBuilder *) classBuilder withProperties:(NSArray<id<ALCMacro>> *) properties;

/**
 Finishes the registration of a class.

 @param classBuilder The ALCBuilder instance representing the class.
 */
-(void) classBuilderDidFinishRegistering:(ALCBuilder *) classBuilder;

/**
 Registers a variable dependency for the classbuilder.

 @discussion Each variable dependency will be injected when the class builder creates an object.

 @param classBuilder	The ALCObjectBuilder instance which represents the class which needs the injected variable.
 @param variable		The name of the variable. Can be the external name in the the case of a property or the internal name. Alchemic will locate and used the internal name regardless of which is specified.
 @param ... One or more macros which define where to get the dependency from. If none are specified then the variable is examined and a set of default ALCModelSearchExpression objects generated which sources the value from the model based on the variable's class and protocols.
 */
-(void) registerClassBuilder:(ALCBuilder *) classBuilder
          variableDependency:(NSString *) variable, ... NS_REQUIRES_NIL_TERMINATION;

-(void) registerClassBuilder:(ALCBuilder *) classBuilder
          variableDependency:(NSString *) variable
                        type:(Class) variableType
            withSourceMacros:(NSArray<id<ALCSourceMacro>> *) sourceMacros;

/**
 Registers an initializer for the current class builder.

 @discussion By registering an initializer with this method, Alchemic will now use the initializer specified rather than the default `init` method.

 When constructing, the number of arguments in the initializer selector must match the number of `AcArg(...)` macros supplied.

 @param classBuilder The parent class builder for the initializer.
 @param initializer  The initializer to use.
 @param ... Zero or more `AcArg(...)` macros which define the arguments of the initializer and where to source them from. Other macros can also be passed here such as `AcFactory`, `AcPrimary` and `AcWithName(...)`.
 */
-(void) registerClassBuilder:(ALCBuilder *) classBuilder
                 initializer:(SEL) initializer, ... NS_REQUIRES_NIL_TERMINATION;

-(void) registerClassBuilder:(ALCBuilder *) classBuilder
                 initializer:(SEL) initializer
              withProperties:(NSArray<id<ALCMacro>> *) properties;

/**
 Registers a method for a class that will create an object.

 @discussion This differs from registerClassBuilder:initializer: in that this doesn't create an instance of the parent class builder. It calls the method on the parent builder object to create an instance of returnType.

 @param classBuilder The parent class builder. This ALCBuilder will be asked for a value, and then the method will be executed on that value.
 @param selector     The selector of the method.
 @param returnType   The type of the object that will be returned from the method.
 @param ... Zero or more `AcArg(...)` macros which define the arguments of the selector and where to source them from. Other macros can also be passed here such as `AcFactory`, `AcPrimary` and `AcWithName(...)`.
 */
-(void) registerClassBuilder:(ALCBuilder *) classBuilder
                    selector:(SEL) selector
                  returnType:(Class) returnType, ... NS_REQUIRES_NIL_TERMINATION;

#pragma mark - Callbacks

/**
 Adds a AcSimpleBlock which is called after Alchemic has finished loading.

 @discussion If Alchemic has not finished it's startup procedure, this block is stored and executed at the end of that procedure. This provides a way for object to know when it is safe to use Alchemic's DI functions.

 If Alchemic has finished it's startup when this is called, the block is simple executed immediately.

 @param block The block to call.
 */
-(void) executeWhenStarted:(AcSimpleBlock) block;

#pragma mark - Lifecycle

/**
 Starts the context.

 @discussion After scanning the runtime for Alchemic registrations, this called to start the context. This involves resolving all dependencies, instantiating all registered singletons and finally injecting any dependencies of those singletons.
 */
-(void) start;

#pragma mark - Dependencies

/**
 Access point for objects which need to have dependencies injected.

 @discussion This checks the model against the model. If a class builder is found which matches the class and protocols of the passed object, it is used to inject any listed dependencies into the object.

 @param object the object which needs dependencies injected.
 */
-(void) injectDependencies:(id) object;

#pragma mark - Setting and retrieving

/**
 Searches the model and returns a value matching the requested type.

 @discussion If no ALCModelSearchExpression objects are passed then the returnType is used to generate a list of class and protocol search expressions and they are used to search the model.

 @param returnType The type of object desired.
 @param ... zero or more ALCModelSearchExpression objects which define where to get the values from.

 @return A value that matches the returnType.
 */
-(id) getValueWithClass:(Class) returnType, ... NS_REQUIRES_NIL_TERMINATION;

- (id)getValueWithClass:(Class)returnType withSourceMacros:(NSArray<id<ALCSourceMacro>> *) sourceMacros;

/**
 Sets the value on a specific builder.

 @param value       The value to be set.
 @param searchMacro A search macro used to locate the builde whose value will be set.
 @param ...         Additional search macros to refine the search for the builder.
 */
-(void) setValue:(id)value inBuilderWith:(id<ALCModelSearchExpression>) searchMacro, ... NS_REQUIRES_NIL_TERMINATION;

-(void) setValue:(id)value inBuilderSearchCriteria:(NSArray<id<ALCModelSearchExpression>> *) criteria;

/**
 Programmatically invokes a specific method.

 @discussion The method can be a normal instance method registered with AcMethod(...) or an initializer registered with AcInitializer(...). Usually you would use this method rather than an injected value when you need to pass values to the method or initializer which are not available from Alchemic's model or a constant value. In other words, values which are computed just prior to requesting the object from Alchemic.

 Note that this method can be used to invoke multiple methods or initializers. In this case it is assumed that each one takes the same arguments in the same order and an array of result objects will be returned.

 @param methodLocator A model search macro which is used to locate the method or initializer to call.
 @param ...  zero or more macros. If model search macros are passed they are added to the method locator. If AcArg(...) macros then they are assumed to be used to find argument values for the method to be invoked.

 @return either an object or an array of objects if multiple builders are found.
 */
-(id) invokeMethodBuilders:(id<ALCModelSearchExpression>) methodLocator, ... NS_REQUIRES_NIL_TERMINATION;

#pragma mark - Working with builders

/**
 Finds the builder for a specific class and returns it.

 @discussion This is mainly an internal function.

 @param aClass The class we want to use as a criteria for finding the builder.

 @return The matching builder or nil if one is not found.
 */
-(nullable ALCBuilder *) classBuilderForClass:(Class) aClass;

/**
 Uses a set of ALCModelSearchExpression objects to find a set of builders in the model.

 @param searchExpressions    A NSSet of ALCModelSearchExpression objects which define the search criteria for finding the builders.
 */
- (NSSet<ALCBuilder *> *)findBuildersWithSearchExpressions:(NSSet<id<ALCModelSearchExpression>> *)searchExpressions;

@end

NS_ASSUME_NONNULL_END
