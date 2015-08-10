//
//  ALCResolverPostProcessor.h
//  alchemic
//
//  Created by Derek Clarkson on 29/04/2015.
//  Copyright (c) 2015 Derek Clarkson. All rights reserved.
//

@import Foundation;
@protocol ALCBuilder;

/**
 Dependency post processors are applied after a list of candidate objects has been returned from a search of the model.
 
 @discussion They provide a mechanism where the candidates can be further filtered or adjusted before the final list is returned.
 */
@protocol ALCDependencyPostProcessor <NSObject>

/**
 Called to process the set of current candidates.

 @param dependencies A NSSet containing the current candidates for the dependency.
 @return a new list of candidates objects. If the post processor didn't change anything then this might be the original dependencies list passed in.
 */
-(nonnull NSSet<id<ALCBuilder>> *) process:(NSSet<id<ALCBuilder>> * _Nonnull) dependencies;

@end
