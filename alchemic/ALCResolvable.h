//
//  ALCResolver.h
//  Alchemic
//
//  Created by Derek Clarkson on 3/08/2015.
//  Copyright © 2015 Derek Clarkson. All rights reserved.
//

@import Foundation;
@protocol ALCDependencyPostProcessor;
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

/**
 Called during model setup to resolve dependencies and validate the model.

 @discussion Normally validation is about detecting circular dependencies. This is done by checking this ALCResolvable against the dependencyStack. If it is present then we have looped around and have a circular dependency.

 @param postProcessors a set of post processors which can be used to resolve results further if needed.
 */
-(void) resolveWithPostProcessors:(NSSet<id<ALCDependencyPostProcessor>> *) postProcessors
                  dependencyStack:(NSMutableArray<id<ALCResolvable>> *) dependencyStack;

@end

NS_ASSUME_NONNULL_END