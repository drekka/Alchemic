//
//  ALCAbstractResolvable.h
//  alchemic
//
//  Created by Derek Clarkson on 2/09/2015.
//  Copyright © 2015 Derek Clarkson. All rights reserved.
//

@import Foundation;
#import "ALCResolvable.h"

/**
 Parent of all resolvable classes.
 */
@interface ALCAbstractResolvable : NSObject<ALCResolvable>

/**
 Returns YES if the resolvable is available for use by other objects.

 @discussion This is established based on a number of criteria including the status of this resolvables dependencies. This property's getter should be overridden to include the checking for objects when necessary.
 */
@property (nonatomic, assign, readonly) BOOL available;

/**
 Call this to trigger call backs when this object becomes available.
 */
-(void) checkIfAvailable;

/**
 Automatically called by checkIfAvailable if the resolvable has just become available.
 */
-(void) didBecomeAvailable;

/**
 Call to get the current resolvable to watch the availability of another resolvable.

 @param resolvable The resolvable to be watched.
 */
-(void) watchResolvable:(ALCAbstractResolvable *) resolvable;

/**
 Adds a block to the current resolvable that is executed when the resolvable becomes vailable. 
 
 @discussion If the resolvable is already available then the block is executed immediately.

 @param whenAvailableBlock The block to be executed. The current resolvable will be passed as a parameter to the block.
 */
-(void) executeWhenAvailable:(ALCResolvableAvailableBlock) whenAvailableBlock;

/**
 Override to process the objects that this resolvable is dependant on.
 
 @discussion You should not call this directly. Instead call resolveWithPostProcessors:dependencyStack:

 @param postProcessors  A NSSet of ALCPostProcessors that can process candidates.
 @param dependencyStack A NSArray representing the stack of resolvables resolving. Used for circular dependency detection.
 */
-(void) resolveDependenciesWithPostProcessors:(NSSet<id<ALCDependencyPostProcessor>> *) postProcessors
                              dependencyStack:(NSMutableArray<id<ALCResolvable>> *) dependencyStack;

@end
