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
@protocol ALCValueResolver;
@protocol ALCModelSearchExpression;
@class ALCClassBuilder;
@protocol ALCBuilder;
@protocol ALCValueDefMacro;

NS_ASSUME_NONNULL_BEGIN

#define ProcessBuiderBlockArgs NSSet<id<ALCBuilder>> *builders
typedef void (^ProcessBuilderBlock)(ProcessBuiderBlockArgs);


@interface ALCContext : NSObject

#pragma mark - Configuration

/**
 Adds an dependency post processor.

 @discussion dependency post processors are executed after depedencies have been resolve and before their values are accessed for injection.
 */
-(void) addDependencyPostProcessor:(id<ALCDependencyPostProcessor>) postProcessor;

#pragma mark - Registration call backs

-(void) registerClassBuilder:(ALCClassBuilder *) classBuilder, ... NS_REQUIRES_NIL_TERMINATION;

-(void) registerClassBuilder:(ALCClassBuilder *) classBuilder variableDependency:(NSString *) variable, ... NS_REQUIRES_NIL_TERMINATION;

-(void) registerClassBuilder:(ALCClassBuilder *) classBuilder initializer:(SEL) initializer, ... NS_REQUIRES_NIL_TERMINATION;

-(void) registerClassBuilder:(ALCClassBuilder *) classBuilder selector:(SEL) selector returnType:(Class) returnType, ... NS_REQUIRES_NIL_TERMINATION;

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

#pragma mark - Retrieving

-(id) getValueWithClass:(Class) returnType, ... NS_REQUIRES_NIL_TERMINATION;

#pragma mark - Working with builders

-(void) addBuilderToModel:(id<ALCBuilder>) builder;

-(void) executeOnBuildersWithSearchExpressions:(NSSet<id<ALCModelSearchExpression>> *) searchExpressions
							  processingBuildersBlock:(ProcessBuilderBlock) processBuildersBlock;

@end

NS_ASSUME_NONNULL_END
