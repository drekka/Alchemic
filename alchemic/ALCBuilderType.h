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
 Defines class that can define the unique functionality that defines how a builder works.
 */
@protocol ALCBuilderType <NSObject>

/**
 The class of the return value created by the builder.
 */
@property (nonatomic, strong, readonly) Class valueClass;

/**
 Returns the name to use for the builder.
 */
@property (nonatomic, strong, readonly) NSString *defaultName;

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

 @param builder The builder than is currently configuring. Normally this is the builder that owns this builder type.
 @param macroProcessor An instance of ALCMacroProcessor that contains the configuration.
 */
-(void) builder:(ALCBuilder *) builder isConfiguringWithMacroProcessor:(ALCMacroProcessor *) macroProcessor;

/**
 Forwarded from the ALCResolvable willResolve method.
 
 @param builder The builder that is resolving. Normally this is the builder that owns this builder type.
 */
-(void) builderWillResolve:(ALCBuilder *) builder;

/**
 Call to directory access the builder using a custom set of values.

 @param arguments An NSarray of the values matching the methods arguments.

 @return The return object from the method with all dependencies injected.
 */
-(id) invokeWithArgs:(NSArray<id> *) arguments;

/**
 Called by the owning ALCBuilder when it needs a ALCBuilder to source variable dependencies from for injecting. 
 
 @discussion Depending on what the builder type is, this can return several things.
 
  * For class builders it returns the parent class builder.
  * For method builders it returns the builder for the return type of the method.
  * For initializer builders it returns the parent class builder.

 @param currentBuilder The current builder which will be the owning builder.

 @return The relevant ALCBuilder as per the above rules.
 */
-(ALCBuilder *) classBuilderForInjectingDependencies:(ALCBuilder *) currentBuilder;

/**
 Called when the builder needs to instantiate an object.

 @return The newly created object.
 */
-(id) instantiateObject;


@end
