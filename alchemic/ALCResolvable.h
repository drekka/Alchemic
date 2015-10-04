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
 Classes that are resolvable can resolve and return values.
 */
@protocol ALCResolvable <NSObject>

#pragma mark - Dependencies

/**
 NSSet of resolvables that the current one depends on for values.
 */
@property(nonatomic, strong, readonly) NSSet<id<ALCResolvable>> *dependencies;

/**
 Call to add anther resolvable as a dependency of this one.

 @param resolvable The resolvable to be added as a dependency.
 */
-(void) addDependency:(id<ALCResolvable>) resolvable;

#pragma mark - Resolving

/**
 When resolving and this is YES, will use a fresh stack for circular dependency
 detection.

 @discussion Circular dependency detection is about detecting circular
 dependencies which alll need to resolve at the same time. For example,
 arguments to methods. When resolving, each resolvable adds itself to the
 dependencyStack before calling it's dependencies to resolve. So by checking the
 stack we can establish if there is a loop. But some resolveables such as
 injected variables are not required immediately because they are injected
 later, so in effect they break the dependency stack.
 */
@property(nonatomic, assign) BOOL startsResolvingStack;

/**
 Initiates resolving using this resolvable as a starting point.
 */
- (void)resolve;

/**
 Override point called before resolving occurs.

 @discussion This is the point there additional dependencies can be generated
 and added if required.
 */
- (void)willResolve;

-(void) didResolve;

#pragma mark - instantiating and injecting

/**
 Returns YES if the resolvable's dependencies are all ready to be injected.
 */
@property(nonatomic, assign, readonly) BOOL ready;

- (void)instantiate;

@end

NS_ASSUME_NONNULL_END