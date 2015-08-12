//
//  ALCModelValueSource.h
//  Alchemic
//
//  Created by Derek Clarkson on 14/07/2015.
//  Copyright © 2015 Derek Clarkson. All rights reserved.
//

@import Foundation;
@class ALCContext;
@protocol ALCModelSearchExpression;
#import "ALCAbstractValueSource.h"

NS_ASSUME_NONNULL_BEGIN

/**
 The main class used to source values from the model.
 */
@interface ALCModelValueSource : ALCAbstractValueSource

/**
 A set of ALCModelSearchExpression objects used to locate the candidates from the model.
 */
@property (nonatomic, strong, readonly) NSSet<id<ALCModelSearchExpression>> *searchExpressions;

/**
 Default initializer.
 
 Do not use.

 @return An instance of this class.
 */
-(instancetype) init NS_UNAVAILABLE;

/**
 Default initializer.

 @param searchExpressions	A NSSet of ALCSearchExpresion objects which will be used to search the model.

 @return An instance of this class.
 */
-(instancetype) initWithSearchExpressions:(NSSet<id<ALCModelSearchExpression>> *) searchExpressions NS_DESIGNATED_INITIALIZER;

@end

NS_ASSUME_NONNULL_END