//
//  ALCAbstractResolvable.h
//  alchemic
//
//  Created by Derek Clarkson on 2/09/2015.
//  Copyright © 2015 Derek Clarkson. All rights reserved.
//

@import Foundation;
#import "ALCResolvable.h"

NS_ASSUME_NONNULL_BEGIN

/**
 Parent of all resolvable classes.
 */
@interface ALCAbstractResolvable : NSObject<ALCResolvable>

/**
 Called during model setup to resolve dependencies and validate the model.

 @discussion Normally validation is about detecting circular dependencies. This is done by checking this ALCResolvable against the dependencyStack. If it is present then we have looped around and have a circular dependency.

 @param postProcessors a set of post processors which can be used to resolve results further if needed.
 which cannot resolve.
 */
-(void) resolveWithDependencyStack:(NSMutableArray<id<ALCResolvable>> *) dependencyStack;

-(BOOL) checkAvailabilityWithInProgress:(NSMutableSet<id<ALCResolvable>> *) inProgress;


@end

NS_ASSUME_NONNULL_END

