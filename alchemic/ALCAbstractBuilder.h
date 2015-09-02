//
//  ALCObjectBuilder.h
//  alchemic
//
//  Created by Derek Clarkson on 23/08/2015.
//  Copyright © 2015 Derek Clarkson. All rights reserved.
//

@import Foundation;
#import "ALCBuilder.h"
@protocol ALCValueStorage;
@protocol ALCInstantiator;

NS_ASSUME_NONNULL_BEGIN

/**
 Base builder for creating objects.

 @discussion This class uses a variety of strategy classes to implement a variety of builder functions.
 */

@interface ALCAbstractBuilder : NSObject<ALCBuilder>

/**
 Provides access to the instantiator used to build the objects that the builder represents.
 */
@property (nonatomic, strong, readonly) id<ALCInstantiator> instantiator;

/**
 Do not use.

 @return An instance of this class.
 */
-(instancetype) init NS_UNAVAILABLE;

/**
 defaul initializer.

 @param instantiator     An instance of ALCInstantiator which implements the code which builds objects and injects them with dependencies.
 @param forClass         The class of the object that the builder will create.

 @return An instance of a ALCBuilder.
 */

-(instancetype) initWithInstantiator:(id<ALCInstantiator>) instantiator
                            forClass:(Class) aClass NS_DESIGNATED_INITIALIZER;

/**
 Call when the builder wants to check if it can instantiate.
 */
-(void) autoBoot;

#pragma mark - Override methods

/**
 Return a set of flags for configuring what macros are accepted by the builder.
 */
@property (nonatomic, assign, readonly) NSUInteger macroProcessorFlags;

/**
 Return YES if the builder can be used. 
 
 @discussion Usually this is always YES, but may be NO if there are dependencies that are waiting on external objects.
 */
@property (nonatomic, assign, readonly) BOOL builderReady;

/**
 Called when the builder has not already been resolved.

 @discussion Override to resolve dependencies for the builder.

 @param postProcessors  Instances of ALCDependencyPostProcessor used for filtering the list of candidate builders for any given dependency.
 @param dependencyStack A stack of already resolved builders representing a path from the first builder resolved. This is used for circular dependency checking.

 */
-(void)resolveDependenciesWithPostProcessors:(NSSet<id<ALCDependencyPostProcessor>> *)postProcessors
                             dependencyStack:(NSMutableArray<id<ALCResolvable>> *)dependencyStack;

/**
 Called when we need to instantiate an object.
 
 @discussion This should in turn make a call to the insantiator being used by this builder.

 @return The objet built by the instantiator.
 */
-(id) instantiateObject;

@end

NS_ASSUME_NONNULL_END