//
//  AlchemicContext.h
//  alchemic
//
//  Created by Derek Clarkson on 15/02/2015.
//  Copyright (c) 2015 Derek Clarkson. All rights reserved.
//

@import Foundation;
@import ObjectiveC;

@protocol ALCDependencyPostProcessor;
@protocol ALCObjectFactory;
@protocol ALCValueResolver;
@protocol ALCModelSearchExpression;
@class ALCClassBuilder;
@protocol ALCBuilder;

NS_ASSUME_NONNULL_BEGIN

#define ProcessBuiderBlockArgs NSSet<id<ALCBuilder>> *builders
typedef void (^ProcessBuilderBlock)(ProcessBuiderBlockArgs);


@interface ALCContext : NSObject

#pragma mark - Configuration

@property (nonatomic, strong, readonly) id<ALCValueResolver> valueResolver;

/**
 Adds an dependency post processor.

 @discussion dependency post processors are executed after depedencies have been resolve and before their values are accessed for injection.
 */
-(void) addDependencyPostProcessor:(id<ALCDependencyPostProcessor>) postProcessor;

/**
 Adds a ALCObjectFactory to the list of object factories.

 @discussion Factories are checked in reverse order. The last registered object factory is the one asked first for an object.

 @param objectFactory the factory to add.
 */
-(void) addObjectFactory:(id<ALCObjectFactory>) objectFactory;

#pragma mark - Registration call backs

-(void) registerDependencyInClassBuilder:(ALCClassBuilder *) classBuilder variable:(NSString *) variable, ... NS_REQUIRES_NIL_TERMINATION;

-(void) registerClassBuilder:(ALCClassBuilder *) classBuilder, ... NS_REQUIRES_NIL_TERMINATION;

-(void) registerClassInitializer:(ALCClassBuilder *) classBuilder initializer:(SEL) initializer, ... NS_REQUIRES_NIL_TERMINATION;

-(void) registerMethodBuilder:(ALCClassBuilder *) classBuilder selector:(SEL) selector returnType:(Class) returnType, ... NS_REQUIRES_NIL_TERMINATION;

#pragma mark - Lifecycle

/**
 Starts the context.

 @discussion After scanning the runtime for Alchemic registrations, this called to start the context. This involves resolving all dependencies, instantiating all registered singletons and finally injecting any dependencies of those singletons.
 */
-(void) start;

-(void) resolveBuilderDependencies;

#pragma mark - Dependencies

/**
 Access point for objects which need to have dependencies injected. 
 
 @discussion This checks the model against the model. If a class builder is found which matches the class and protocols of the passed object, it is used to inject any listed dependencies into the object.
 
 @param object the object which needs dependencies injected.
 */
-(void) injectDependencies:(id) object;

#pragma mark - Working with builders

-(void) addBuilderToModel:(id<ALCBuilder>) builder;

-(void) executeOnBuildersWithSearchExpressions:(NSSet<id<ALCModelSearchExpression>> *) searchExpressions
							  processingBuildersBlock:(ProcessBuilderBlock) processBuildersBlock;

@end

NS_ASSUME_NONNULL_END
