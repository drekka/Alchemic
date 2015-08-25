//
//  NSObject+ALCResolvable.h
//  alchemic
//
//  Created by Derek Clarkson on 20/08/2015.
//  Copyright © 2015 Derek Clarkson. All rights reserved.
//

@import Foundation;
#import "ALCResolvable.h"

NS_ASSUME_NONNULL_BEGIN

/**
 Methods for working with objects which implement the ALCResolvable protocol.
 */
@interface NSObject (ALCResolvable)

/**
 Adds KVO watches to the state field.

 @param resolvables A NSSet of resolveables.
 */
-(void) kvoWatchAvailableInResolvableArray:(NSArray<NSObject<ALCResolvable> *> *) resolvables;

/**
 Removes KVO watches on the state field from a list of resolvables.

 @param resolvables A NSSet of resolvables.
 */
-(void) kvoRemoveWatchAvailableFromResolvableArray:(NSArray<NSObject<ALCResolvable> *> *) resolvables;

/**
 Adds KVO watches to the state field.

 @param resolvables A NSSet of resolveables.
 */
-(void) kvoWatchAvailableInResolvableSet:(NSSet<NSObject<ALCResolvable> *> *) resolvables;

/**
 Removes KVO watches on the state field from a list of resolvables.

 @param resolvables A NSSet of resolvables.
 */
-(void) kvoRemoveWatchAvailableFromResolvableSet:(NSSet<NSObject<ALCResolvable> *> *) resolvables;

/**
 Adds KVO watches to the state field.

 @param resolvable A id<ALCResolvable> instance.
 */
-(void) kvoWatchAvailable:(NSObject<ALCResolvable> *) resolvable;

/**
 Removes KVO watches on the state field from a list of resolvables.

 @param resolvable A id<ALCResolvable> instance.
 */
-(void) kvoRemoveWatchAvailable:(NSObject<ALCResolvable> *) resolvable;

@end

NS_ASSUME_NONNULL_END