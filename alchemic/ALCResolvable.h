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
#define ALCResolvableAvailableBlockArgs id<ALCResolvable> resolvable
typedef void (^ALCResolvableAvailableBlock) (ALCResolvableAvailableBlockArgs);

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

 @param whenAvailableBlock The block to execute.
 */
-(void) executeWhenAvailable:(ALCResolvableAvailableBlock) whenAvailableBlock;

#pragma mark - Resolving

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

#pragma mark - Availability

/**
 Call this to trigger availability checking on the current resolvable and it's dependencies.
 */
-(void) checkIfAvailable;

/**
 Automatically called by checkIfAvailable if the resolvable has just become available.

 @discussion This is an override point where sub classes can enact behaviour when the resolvable becomes available. For example they might create instances.
 */
-(void) didBecomeAvailable;

/**
 Returns YES if the resolvable is available for use by other objects.

 @discussion This is established based on a number of criteria including the status of this resolvables dependencies. This property's getter should be overridden to include the checking for objects when necessary.
 */
@property (nonatomic, assign, readonly) BOOL available;

@end

NS_ASSUME_NONNULL_END