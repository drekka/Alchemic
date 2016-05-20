//
//  NSArray+Alchemic.h
//  Alchemic
//
//  Created by Derek Clarkson on 22/03/2016.
//  Copyright © 2016 Derek Clarkson. All rights reserved.
//

@import Foundation;

#import <Alchemic/ALCTypeDefs.h>

@protocol ALCDependency;
@protocol ALCInjector;
@protocol ALCModel;
@protocol ALCResolvable;

NS_ASSUME_NONNULL_BEGIN

/**
 NSArray extensions.
 */
@interface NSArray (Alchemic)

/// @name Analysing array contents

/**
 Converts a list of arguments for methods into a set of dependencies, ready for use by a method factory.
 
 @param unknownArgumentHandler A block that is called if the current argumet is unknown.
 
 @return A list of ALCDependencies, one per argument.
 */
-(NSArray<id<ALCDependency>> *) methodArgumentsWithUnknownArgumentHandler:(void (^)(id argument)) unknownArgumentHandler;

/**
 Scans a list of seach criteria or constants to define an injection.
 
 @param injectionClass The class of the target injection. Used to provide default search criteria when there is none in the list.
 @param allowConstants If YES, allows constants to be defined for the injection. If NO and a constant is detected in the list, an exception will be thrown.
 
 @return An injector which is ready to set values as defined by the list.
 */
-(id<ALCInjector>) injectionWithClass:(Class) injectionClass allowConstants:(BOOL) allowConstants;

/// @name Resolving

/**
 Loops through the arguments in the list and resolves them.
 
 @param resolvingStack The current resolving stack.
 @param model          The model.
 */
-(void)resolveArgumentsWithStack:(NSMutableArray<id<ALCResolvable>> *)resolvingStack model:(id<ALCModel>) model;

/**
 Asks the list of dependencies if they are ready for injection.
 
 @param checkingFlag A reference to a variable in the calling class which is used to indicate if it is currently checking it's ready status. If this is currently YES then the thread has looped back via a circular reference.
 
 @return YES if all dependencies are ready for injection.
 */
-(BOOL) dependenciesReadyWithCurrentlyCheckingFlag:(BOOL *) checkingFlag;

/// @name Tasks

/**
 Combines a list of ALCSimpleBlock objects into a single block.
 
 @return A block which will execute all the blocks in the list.
 */
-(nullable ALCSimpleBlock) combineSimpleBlocks;

@end

NS_ASSUME_NONNULL_END

