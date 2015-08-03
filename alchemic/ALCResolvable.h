//
//  ALCResolver.h
//  Alchemic
//
//  Created by Derek Clarkson on 3/08/2015.
//  Copyright © 2015 Derek Clarkson. All rights reserved.
//

@import Foundation;
@protocol ALCDependencyPostProcessor;

@protocol ALCResolvable <NSObject>

/**
 Called during model setup to resolve dependencies into a list of candidate objects.

 @param postProcessors a set of post processors which can be used to resolve results further if needed.
 */
-(void) resolveWithPostProcessors:(NSSet<id<ALCDependencyPostProcessor>> *) postProcessors;

/**
 Called during model setup to validate dependencies.
 */
-(void) validateWithDependencyStack:(NSMutableArray<id<ALCResolvable>> *) dependencyStack;

@end
