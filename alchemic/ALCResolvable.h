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
 Classes that are resolvable can resolve dependencies agaist the model.
 */
@protocol ALCResolvable <NSObject>

/**
 If the resolvable has already been resolved by the resolveWithPostProcessors: method.
 */
@property (nonatomic, assign, readonly) BOOL resolved;

/**
 Called during model setup to resolve dependencies into a list of candidate objects.

 @param postProcessors a set of post processors which can be used to resolve results further if needed.
 */
-(void) resolveWithPostProcessors:(NSSet<id<ALCDependencyPostProcessor>> *) postProcessors;

/**
 Called during model setup to validate dependencies.
 
 @discussion Normally this is about detecting circular dependencies. This is done by checking this ALCResolvable against the dependencyStack. If it is present then we have looped around and have a circular dependency.

 @param dependencyStack An NSArray containing the ALCBuilder instances and ALCDependency instances that have been validated so far.
 */
-(void) validateWithDependencyStack:(NSMutableArray<id<ALCResolvable>> *) dependencyStack;

@end

NS_ASSUME_NONNULL_END