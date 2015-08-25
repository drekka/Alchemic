//
//  ALCResolver.h
//  Alchemic
//
//  Created by Derek Clarkson on 3/08/2015.
//  Copyright © 2015 Derek Clarkson. All rights reserved.
//

@import Foundation;
@protocol ALCDependencyPostProcessor;

NS_ASSUME_NONNULL_BEGIN

/**
 Classes that are resolvable can resolve and return values.
 */
@protocol ALCResolvable <NSObject>

/**
 Indicates that the resolvables value can be accessed and a value is either present or can be created.
 
 @discussion This is about supporting externally created objects which are injected into Alchemic at some future time. Until those objects are injected, the resolvable is marked as not being available. Builders can then watch this property to known when the resolvable is available.
 */
@property (nonatomic, assign, readonly) BOOL available;

/**
 Called during model setup to resolve dependencies and validate the model.

 @discussion Normally validation is about detecting circular dependencies. This is done by checking this ALCResolvable against the dependencyStack. If it is present then we have looped around and have a circular dependency.

 @param postProcessors a set of post processors which can be used to resolve results further if needed.
 */
-(void) resolveWithPostProcessors:(NSSet<id<ALCDependencyPostProcessor>> *) postProcessors
                  dependencyStack:(NSMutableArray<id<ALCResolvable>> *) dependencyStack;

@end

NS_ASSUME_NONNULL_END