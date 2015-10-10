//
//  ALCBuilderType.h
//  alchemic
//
//  Created by Derek Clarkson on 4/09/2015.
//  Copyright © 2015 Derek Clarkson. All rights reserved.
//

@import Foundation;
@import ObjectiveC;
@class ALCMacroProcessor;
@protocol ALCBuilderStorage;
@protocol ALCResolvable;
@protocol ALCDependencyPostProcessor;
@class ALCBuilder;
@class ALCValueSourceFactory;

/**
 Used to define what the type creates.
 */
typedef NS_ENUM(NSUInteger, ALCBuilderType){
    /**
     Builds classes.
     */
    ALCBuilderTypeClass,
    /**
     Builds objects using methods.
     */
    ALCBuilderTypeMethod,
    /**
     Builds objects using their class initializers.
     */
    ALCBuilderTypeInitializer
};

/**
 Defines class that can define the unique functionality that defines how a builder works.
 */
@protocol ALCBuilderType <NSObject>

/**
 A weak reference back to the builder that owns this instance. 
 
 @discussion This weak reference is to allow the builder type to further configure the builder.
 In future this could probably be removed in future and replaced by further calls to the builder type.
 */
@property (nonatomic, weak) ALCBuilder *builder;

/**
 Returns the name to use for the builder.
 */
@property (nonatomic, strong, readonly) NSString *builderName;

/**
 USed by debug methods to get a description of the attributes of the builder type.
 */
@property (nonatomic, strong, readonly) NSString *attributeText;

/**
 Returns YES if the builder is ready to inject dependencies.
 */
@property (nonatomic, assign, readonly) BOOL canInjectDependencies;

/**
 Return a set of flags for configuring what macros are accepted by the builder.
 */
@property (nonatomic, assign, readonly) NSUInteger macroProcessorFlags;

/**
 Configures the builder type using instructions read into the passed macro processor.

 @param macroProcessor An instance of ALCMacroProcessor that contains the configuration.
 */
-(void) configureWithMacroProcessor:(ALCMacroProcessor *) macroProcessor;

/**
 Forwarded from the ALCResolvable willResolve method.
 */
-(void) willResolve;

/**
 Adds a variable injection to the builder type.

 @param variable           The variable to be injected.
 @param valueSourceFactory A ALCValueSourceFactory that defines where to get the value to inject.
 */
-(void) addVariableInjection:(Ivar) variable
          valueSourceFactory:(ALCValueSourceFactory *) valueSourceFactory;

/**
 Call to directory access the builder using a custom set of values.

 @param arguments An NSarray of the values matching the methods arguments.

 @return The return object from the method with all dependencies injected.
 */
-(id) invokeWithArgs:(NSArray<id> *) arguments;

/**
 Called when the builder needs to instantiate an object.

 @return The newly created object.
 */
-(id) instantiateObject;

/**
 Injects an object passed to the builder.

 @param object The object which needs dependencies injected.
 */
-(void)injectDependencies:(id) object;

@end
