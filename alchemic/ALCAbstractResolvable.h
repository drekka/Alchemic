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
 Call this to trigger call backs when this object becomes available.
 */
-(void) checkIfAvailable;

/**
 Automatically called by checkIfAvailable if the resolvable has just become available.
 */
-(void) didBecomeAvailable;

-(void) watchResolvable:(id<ALCResolvable>) resolvable;

/**
 Override to process the objects that this resolvable is dependant on.
 
 @discussion You should not call this directly. Instead call resolveWithPostProcessors:dependencyStack:

 @param postProcessors  A NSSet of ALCPostProcessors that can process candidates.
 @param dependencyStack A NSArray representing the stack of resolvables resolving. Used for circular dependency detection.
 */
-(void) resolveDependenciesWithPostProcessors:(NSSet<id<ALCDependencyPostProcessor>> *) postProcessors
                              dependencyStack:(NSMutableArray<id<ALCResolvable>> *) dependencyStack;

@end
