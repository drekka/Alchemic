//
//  ALCArgument.h
//  Alchemic
//
//  Created by Derek Clarkson on 14/07/2015.
//  Copyright © 2015 Derek Clarkson. All rights reserved.
//

@import Foundation;
@import ObjectiveC;
#import "ALCResolvable.h"

NS_ASSUME_NONNULL_BEGIN

@protocol ALCDependencyPostProcessor;

/**
 Objects that can produce values for dependencies.
 */
@protocol ALCValueSource <NSObject, ALCResolvable>

/**
 The value.
 */
@property (nonatomic, strong, readonly) id value;

/**
 The expected class.
 */
@property (nonatomic, strong, readonly) Class valueClass;

/**
 Called during dependency resolving to tell the dependency to resolve itself against the model.
 
 @param postProcessors A NSSet of ALCDependencyPostProcessors that can be applied to resolved values.
 */
-(void) resolveWithPostProcessors:(NSSet<id<ALCDependencyPostProcessor>> *) postProcessors;

@end

NS_ASSUME_NONNULL_END