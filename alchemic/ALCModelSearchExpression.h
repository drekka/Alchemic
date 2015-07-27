//
//  ALCModelSearchExpression.h
//  Alchemic
//
//  Created by Derek Clarkson on 15/07/2015.
//  Copyright © 2015 Derek Clarkson. All rights reserved.
//

@import Foundation;
@protocol ALCBuilder;
@protocol ALCSearchableBuilder;

/**
 Classes which can be used to search the model.
 */
@protocol ALCModelSearchExpression <NSObject>

@property (nonatomic, assign, readonly) int priority;
@property (nonatomic, strong, readonly) id cacheId;

-(BOOL) matches:(id<ALCSearchableBuilder>) builder;

@end
