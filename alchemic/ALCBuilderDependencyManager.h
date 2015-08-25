//
//  ALCBuilderDependencyManager.h
//  alchemic
//
//  Created by Derek Clarkson on 24/08/2015.
//  Copyright © 2015 Derek Clarkson. All rights reserved.
//

@import Foundation;
@class ALCDependency;
#import "ALCResolvable.h"

NS_ASSUME_NONNULL_BEGIN

/**
 Manages the dependencies for a builder.
 */
@interface ALCBuilderDependencyManager<dependencyType:ALCDependency *> : NSObject<ALCResolvable>

/**
 Returns the number of stored dependencies.
 */
@property (nonatomic, assign, readonly) NSUInteger numberOfDependencies;

/**
 Returns the values of the dependencies as an array.
 */
@property (nonatomic, strong, readonly) NSArray *dependencyValues;

/**
 Adds a dependency to the manager.

 @param dependency The dependency to add.
 */
-(void) addDependency:(dependencyType) dependency;

/**
 Loops over the stored dependencies and executes a block.

 @param block The block to execute. Has 3 arguments: The dependency, it's index in the arrya of dependencies and a BOOL stop reference which can be set to YES to stop the iteration.
 */
-(void) enumerateDependencies:(void (^)(dependencyType dependency, NSUInteger idx, BOOL *stop)) block;

@end

NS_ASSUME_NONNULL_END