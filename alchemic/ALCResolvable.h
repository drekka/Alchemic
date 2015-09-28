//
//  ALCResolver.h
//  Alchemic
//
//  Created by Derek Clarkson on 3/08/2015.
//  Copyright © 2015 Derek Clarkson. All rights reserved.
//

@import Foundation;
@protocol ALCResolvable;

NS_ASSUME_NONNULL_BEGIN

/**
 Defines a block used when making callbacks to objects to indicates that a resolvable can now be instantiated.
 */
#define ALCDependencyReadyBlockArgs id<ALCResolvable> resolvable
typedef void (^ALCDependencyReadyBlock) (ALCDependencyReadyBlockArgs);

/**
 Classes that are resolvable can resolve and return values.
 */
@protocol ALCResolvable <NSObject>

#pragma mark - Dependencies

/**
 NSSet of resolvables that the current one depends on for values.
 */
@property (nonatomic, strong, readonly) NSSet<id<ALCResolvable>> *dependencies;

/**
 Call to get the current resolvable to watch the availability of another resolvable.

 @discussion If the other resolvable is already available then nothing will happen. However if the other resolvable is not currently available this this resolvable is also regarded as not available. It will then ask the other resolvable to notify it when it becomes available. When that occurs the current resolvable will then re-check it's own availaility.

 @param resolvable The resolvable to be watched.
 */
-(void) addDependency:(id<ALCResolvable>) resolvable;

/**
 Executes the passed block when the resolvable becomes available.
 
 @discussion If the resolvable is already available then the block will be immediately exexcuted.

 @param dependencyReadyBlock The block to execute.
 */
-(void) whenReadyToInject:(ALCDependencyReadyBlock) dependencyReadyBlock;

#pragma mark - Resolving

/**
 True when the resolvable has resolved all it's dependencies.
 */
@property (nonatomic, assign) BOOL resolved;

/**
 When resolving and this is YES, will use a fresh stack for circular dependency detection.

 @discussion Circular dependency detection is about detecting circular dependencies which alll need to resolve at the same time. For example, arguments to methods. When resolving, each resolvable adds itself to the dependencyStack before calling it's dependencies to resolve. So by checking the stack we can establish if there is a loop. But some resolveables such as injected variables are not required immediately because they are injected later, so in effect they break the dependency stack.
 */
@property (nonatomic, assign) BOOL startsResolvingStack;

/**
 Initiates resolving using this resolvable as a starting point.
 */
-(void) resolve;

/**
 Override point called before resolving occurs. 
 
 @discussion This is the point there additional dependencies can be generated and added if required.
 */
-(void) willResolve;

/**
 Override point which is called when a resolvable resolves.
 */
-(void) didResolve;

#pragma mark - instantiating and injecting

/**
 Returns YES if the resolvable can be instantiated.

 @discussion This is established based on a number of criteria including the status of this resolvables dependencies. This property's getter should be overridden to include the checking for objects when necessary.
 */
@property (nonatomic, assign, readonly) BOOL ready;

-(void) instantiate;

@end

NS_ASSUME_NONNULL_END