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
@class ALCModelSearchCriteria;
@class ALCType;

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
-(NSArray<id<ALCDependency>> *) methodArgumentsWithTypes:(NSArray<ALCType *> *) types
                                  unknownArgumentHandler:(void (^)(id argument)) unknownArgumentHandler;

-(ALCModelSearchCriteria *) modelSearchCriteriaForClass:(Class) aClass;

/// @name Resolving

/**
 Loops through the resolvables in the list and resolves them.
 
 @param resolvingStack The current resolving stack.
 @param model          The model.
 */
-(void)resolveWithStack:(NSMutableArray<id<ALCResolvable>> *)resolvingStack model:(id<ALCModel>) model;

/**
 Asks the list of dependencies if they are ready for injection.
 
 @param checkingFlag A reference to a variable in the calling class which is used to indicate if it is currently checking it's ready status. If this is currently YES then the thread has looped back via a circular reference.
 
 @return YES if all dependencies are ready for injection.
 */
-(BOOL) dependenciesReadyWithCheckingFlag:(BOOL *) checkingFlag;

@end

NS_ASSUME_NONNULL_END

