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

@interface ALCModelValueSource : ALCAbstractValueSource

@property (nonatomic, strong, readonly) NSSet<id<ALCModelSearchExpression>> *searchExpressions;

-(instancetype) init NS_UNAVAILABLE;

-(instancetype) initWithSearchExpressions:(NSSet<id<ALCModelSearchExpression>> *) searchExpressions NS_DESIGNATED_INITIALIZER;

@end

NS_ASSUME_NONNULL_END