//
//  ALCResolver.h
//  alchemic
//
//  Created by Derek Clarkson on 17/04/2015.
//  Copyright (c) 2015 Derek Clarkson. All rights reserved.
//

@import Foundation;

@protocol ALCDependencyPostProcessor;
@protocol ALCValueSource;
#import "ALCResolvable.h"

NS_ASSUME_NONNULL_BEGIN

/**
 Represents a single dependency of a variable or method argument.
 
 @discussion ALCDependency objects are the core link between a ALCBuilder and the values it needs. A builder will define a dependency for any variables it needs (in the case of ALCClassBuilder) or method arguments. Each ALCDependency contains a class reference representing the type of object that will be set and a ALCArgument instance that defines where to get it from.
 */
@interface ALCDependency : NSObject<ALCResolvable>

/**
 The value. 

 @discussion Normally the value is not resolved until this property is accessed.
 */
@property (nonatomic, strong, readonly) id value;

/**
 The value source that will provide the value for the dependency.
 */
@property (nonatomic, strong, readonly) id<ALCValueSource> valueSource;

#pragma mark - Resolving

/**
 Called when resolving candiate ALCBuilders for a dependency.
 
 @discussion This call gives the post processors a chance to process the candidates before they are stored as the final set.

 @param postProcessors	A NSSet of ALCPostProcessor instances.
 */
-(void) resolveWithPostProcessors:(NSSet<id<ALCDependencyPostProcessor>> *) postProcessors;

/**
 Default initializer.

 @param valueSource An ALCArgument instance which can source the value.

 @return An instance of this class.
 */
-(instancetype) initWithValueSource:(id<ALCValueSource>) valueSource;

@end

NS_ASSUME_NONNULL_END