//
//  ALCInstantiationResult.h
//  Alchemic
//
//  Created by Derek Clarkson on 9/03/2016.
//  Copyright © 2016 Derek Clarkson. All rights reserved.
//

@import Foundation;

@protocol ALCContext;

#import "ALCDefs.h"

NS_ASSUME_NONNULL_BEGIN

/**
 @brief An instantiation contains a created object and an optional completion block that can be called to finish injecting values into the object. 
 
 The instantation of an instance of an object and performing injects of it is separated like this because we want to delay injections so that all objects get created before injections are performed. Note: that this won't work so we with method and initializers because argument values mush be fully instantiated before the method is called.
 */
@interface ALCInstantiation : NSObject

/**
 @brief Factory method for creation an ALCInstantion instance populated with an object and completion.
 
 @param object     The object to store.
 @param completion The objects completion block.
 
 @return An instance of this class.
 */
+(instancetype) instantiationWithObject:(id) object completion:(nullable ALCObjectCompletion) completion;

/**
 @brief The stored object.
 */
@property (nonatomic, strong, readonly) id object;

/**
 @brief Combines the stored completion and a new completion. 
 
 Usually the new completion is a block that represents completions from other dependencies. This method also handles if either block is NULL.
 
 @param newCompletion The block to add to the current completion.
 */
-(void) addCompletion:(nullable ALCObjectCompletion) newCompletion;

/**
 @brief Tells the instantiation to execute it's completion block.
 
 This also notifies the object of the completion being execute and issues the AlchemicDidCreateObject notification.
 */
-(void) complete;

@end

NS_ASSUME_NONNULL_END
