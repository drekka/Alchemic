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
 Classes which can be used to search the model.
 */
@protocol ALCModelSearchExpression <NSObject>

@property (nonatomic, strong, readonly) id cacheId;

-(BOOL) matches:(id<ALCBuilder>) builder;

@end
