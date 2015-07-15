//
//  ALCModelSearchExpression.h
//  Alchemic
//
//  Created by Derek Clarkson on 15/07/2015.
//  Copyright © 2015 Derek Clarkson. All rights reserved.
//

@import Foundation;
@protocol ALCBuilder;

#define ALCMatchBuilderBlockArgs id<ALCBuilder> builder
typedef BOOL (^ALCMatchBuilderBlock)(ALCMatchBuilderBlockArgs);

/**
 Indicates what type of qualifier this is.

 @discussion This enum serves a secondary purpose in that the integer values server as the sorting criteria for determining the order in which qualifiers are processed. Hence strings are first as they represent object names and are more likely to produce small lists. Then classes, then protocols.
 */
typedef NS_ENUM(NSUInteger, ALCModelSearchExpressionType) {
    ALCModelSearchExpressionTypeString = -1,
    ALCModelSearchExpressionTypeClass = 0,
    ALCModelSearchExpressionTypeProtocol = 1
};

/**
 Classes which can be used to search the model.
 */
@protocol ALCModelSearchExpression <NSObject>

@property (nonatomic, strong, readonly) id cacheId;
@property (nonatomic, assign, readonly) ALCModelSearchExpressionType type;
@property (nonatomic, copy, readonly) ALCMatchBuilderBlock matchBlock;


@end
