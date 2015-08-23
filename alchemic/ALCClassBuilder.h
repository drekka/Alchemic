//
//  ALCConstructorInfo.h
//  alchemic
//
//  Created by Derek Clarkson on 23/02/2015.
//  Copyright (c) 2015 Derek Clarkson. All rights reserved.
//

@import Foundation;
@import ObjectiveC;

#import "ALCAbstractBuilder.h"
@class ALCMacroProcessor;
@class ALCClassInitializerBuilder;
@class ALCMethodBuilder;

NS_ASSUME_NONNULL_BEGIN

/**
 An ALCBuilder that creates objects from class definitions.

 @discussion An instance of this builder is created in the model as soon as an Alchemic method is detected in the class definition during runtime scanning. Only if an ALCInitializerBuilder is also created is it removed. This allows for the model search routines to find the initializer instead of the class builder and therefore correctly create instances using it.

 If an ALCInitializerBuilder is not created and an `AcRegister(...)` macro is encountered then this builder will be used to create objects. If `AcMethod(...)` factory methods are detected then this builder will also be set as their parent so it can be instantiated when needed before the method is called.
 */
@interface ALCClassBuilder : ALCAbstractBuilder

/**
 When YES, means that the value is not to be generated as it will be set from an external source.

 @discussion At the moment only class builder can be external, but we need to consider it in various methods. External is mutually exclusive with factory.
 */
@property (nonatomic, assign, readonly) BOOL external;

/**
 Default initializer.
 
 @warning Do not use.
 @return An instance of this class.
 */
-(instancetype) init NS_UNAVAILABLE;

/**
 Default initializer.
 
 @param valueClass The class of the object that will be returned by the builder.
 @return A fully injected instance of valueClass.
 */
-(instancetype) initWithValueClass:(Class) valueClass NS_DESIGNATED_INITIALIZER;

/**
 Adds the definition of a variable to be injected when the build is asked for an object.
 
 @param variable       An IVar reference to the variable to be set.
 @param aClass         The class of the variable.
 @param macroProcessor An instance of ALCMacroProcessor which contains the definition of the value to be set.
 */
-(void) addVariableInjection:(Ivar) variable class:(Class) aClass macroProcessor:(ALCMacroProcessor *) macroProcessor;

@end

NS_ASSUME_NONNULL_END
