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

typedef NS_ENUM(NSUInteger, ALCBuilderType) {
    ALCBuilderTypeClass,
    ALCBuilderTypeMethod,
    ALCBuilderTypeInitializer
};

/**
 Defines class that can define the unique functionality that defines how a builder works.
 */
@protocol ALCBuilderType <NSObject>

@property (nonatomic, weak) ALCBuilder *builder;

@property (nonatomic, assign, readonly) ALCBuilderType type;

/**
 Returns the name to use for the builder.
 */
@property (nonatomic, strong, readonly) NSString *builderName;

@property (nonatomic, strong, readonly) NSString *attributeText;

@property (nonatomic, assign, readonly) BOOL canInjectDependencies;

/**
 Return a set of flags for configuring what macros are accepted by the builder.
 */
@property (nonatomic, assign, readonly) NSUInteger macroProcessorFlags;

-(void) configureWithMacroProcessor:(ALCMacroProcessor *) macroProcessor;

/**
 Forwarded from the ALCResolvable willResolve method.
 */
-(void) willResolve;

-(void) addVariableInjection:(Ivar) variable
          valueSourceFactory:(ALCValueSourceFactory *) valueSourceFactory;

/**
 Call to directory access the builder using a custom set of values.

 @param arguments An NSarray of the values matching the methods arguments.

 @return The return object from the method with all dependencies injected.
 */
-(id) invokeWithArgs:(NSArray<id> *) arguments;

-(id) instantiateObject;

/**
 Injects an object passed to the builder.

 @param object The object which needs dependencies injected.
 */
-(void)injectDependencies:(id) object;

@end
