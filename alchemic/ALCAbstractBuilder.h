//
//  ALCModelObject.h
//  alchemic
//
//  Created by Derek Clarkson on 8/05/2015.
//  Copyright (c) 2015 Derek Clarkson. All rights reserved.
//

@import Foundation;

@class ALCMacroProcessor;
@class ALCDependency;

#import "ALCBuilder.h"

NS_ASSUME_NONNULL_BEGIN

/**
 Abstract parent class of all ALCBuilder objects. 
 
 @discussion This class provides common code that all the sub classes use.
 */
@interface ALCAbstractBuilder : NSObject<ALCBuilder>

/// @name Settings

/** 
 The class of the value that will be returned by the builder.
 
 @discussion This is mainly used when Alchemic is searching the model to find builders that can create an instance of a specific class or potocol.
*/
@property (nonatomic, strong) Class valueClass;

/**
 The name assigned to the builder.

 @discussion This is mainly used when Alchemic is searching the model to find builders with a specific name. Names can be anything you like and more than one object can have the same name. By default, various builders assign names if one is not specified by the `AcWithName(...)` macro.
 */
@property (nonatomic, strong) NSString *name;

/** 
 Set if the builder is not a factory.
 
 @discussion When Alchemic is creating singletons on startup, it checks this flag to decide if the builder should be asked for a singleton instance. The flag will also return NO if the builder already has a value stored. This can be the case if a previous builder triggered the value to be created during the singleton startup process. Hence we do not want to create another instance.
*/
@property (nonatomic, assign) BOOL createOnBoot;

/** 
 If the builder is to be regarded as a primary builder.
 
 @discussion Primary builders are given preference over non-primary builders. When the model is searched for builders to satisfy an ALCDependency, if there is at least one primary builder in the results, then all non-primary builders are dropped from the set. 
 
 Primary builders are most useful during testing. A dummy class can be created in the test code and designated as a primary. When Alchemic starts this primary will then effectively override the production version of the class.
*/
@property (nonatomic, assign) BOOL primary;

/**
 If the builder is a factory.

 @discussion Factory builders do not cache the value when they create it. Instead they create a new object each time they are asked for a value.
 */
@property (nonatomic, assign) BOOL factory;

/**
 The ALCMacroProcessor instance that will process the macro arguments from the code.
 */
@property (nonatomic, strong) ALCMacroProcessor *macroProcessor;

/**
 An NSArray of ALCDependency objects associated with the builder. 
 
 @discussion This is an array because builders which call methods need to know which dependency is associated with what method argument and the indexes of the dependencies are used to do this match.
 */
@property (nonatomic, strong, readonly) NSMutableArray<ALCDependency *> *dependencies;

/// @name Creation

/**
 Called to create the object by the [ALCBuilder instantiate] method.
 
 @discussion This method is overridden in each builder to create an object according to how the builder is designed to do that. [ALCBuilder instantiate] is where the object is managed and should not be overridden.
 @return An instance of the object that the builder has built.
 */
-(id) instantiateObject;

/// @name Validation

/**
 Validates that the passed selector occurs on the passed class and has a correct set of arguments stored in the macro processor.
 
 @param aClass The class to be used to check the selector again.
 @param selector The selector to check.
 @param macroProcessor An instance of ALCMacroProcessor containing the dependencies that will be required for the selector to be called.
 @exception NSException If there is a problem.
 */
-(void) validateClass:(Class) aClass selector:(SEL)selector macroProcessor:(ALCMacroProcessor *) macroProcessor;

/**
 Returns the state of the object as a string.

 @discussion This is mostly used for debug logging.

 @return A string representing the state.
 */
-(NSString *) stateDescription;

/**
 Returns the attributes of the object as a string.

 @discussion This is mostly used for debug logging. Typically it displays if the builder is a factory.

 @return A string representing the attributes.
 */
-(NSString *) attributesDescription;

@end

NS_ASSUME_NONNULL_END