//
//  ALCValueSource.h
//  Alchemic
//
//  Created by Derek Clarkson on 27/8/16.
//  Copyright © 2016 Derek Clarkson. All rights reserved.
//

@import Foundation;

#import "ALCResolvable.h"

@class ALCValue;
@protocol ALCObjectFactory;

NS_ASSUME_NONNULL_BEGIN

@protocol ALCValueSource <ALCResolvable>

/**
 Returns the value source's value.
 
 This can return an object, array of objects, or a NSValue containing a scalar value.
 */
@property (nonatomic, strong, nullable, readonly) ALCValue *value;

/**
 Returns YES if the value source references at least one object factory that is set as transient.
 */
@property (nonatomic, assign, readonly) BOOL referencesTransients;

/**
 Returns YES if the passed object factory is referenced by this injector.

 @discussion This is a facade method to provide access to the same method on the dependencies internal injector.

 @param objectFactory The object factory to query for.
 */
-(BOOL) referencesObjectFactory:(id<ALCObjectFactory>) objectFactory;

@end

NS_ASSUME_NONNULL_END
