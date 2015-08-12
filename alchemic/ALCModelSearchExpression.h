//
//  ALCModelSearchExpression.h
//  Alchemic
//
//  Created by Derek Clarkson on 15/07/2015.
//  Copyright © 2015 Derek Clarkson. All rights reserved.
//

@import Foundation;
@protocol ALCBuilder;

/**
 Classes which can be used to search the model implement this protocol.
 */
@protocol ALCModelSearchExpression <NSObject>

/**
 Priorty is used to sort a group of search expressions.
 
 @discussion The idea is to place expressions which are more likely to produce the smallest number of candidaes first. This means that subsequent expressions will have smaller lists of candidates to deal with.
 */
@property (nonatomic, assign, readonly) int priority;

/**
 The cache Id of the results from this expression.
 
 @discussion The results of expression searches of the model are cached for speed.
 */
@property (nonatomic, strong, readonly) id cacheId;

/**
 Called to decide if a specific ALCBuilder will be matched by the current ALCSearchExpression.

 @param builder The builder to be tested.

 @return YES if the builder is a match for the expression.
 */
-(BOOL) matches:(id<ALCBuilder>) builder;

@end
