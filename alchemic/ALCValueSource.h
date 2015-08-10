//
//  ALCValueSource.h
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
 Called to obtain a value based on a passed in type.
 
 @discussion this allows the value source to do any additional processing of the value depending on the finalType class.
 
 @param finalType The class of the object that is expected to be returned.
 @return The final value.
 */
-(id) valueForType:(nullable Class) finalType;

/**
 Called during dependency resolving to tell the dependency to resolve itself against the model.
 
 @param postProcessors A NSSet of ALCDependencyPostProcessors that can be applied to resolved values.
 */
-(void) resolveWithPostProcessors:(NSSet<id<ALCDependencyPostProcessor>> *) postProcessors;

@end

NS_ASSUME_NONNULL_END