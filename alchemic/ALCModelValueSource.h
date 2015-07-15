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

#import "ALCValueSource.h"

NS_ASSUME_NONNULL_BEGIN

@interface ALCModelValueSource : NSObject<ALCValueSource>

-(instancetype) initWithContext:(ALCContext __weak *) context
              searchExpressions:(NSSet<id<ALCModelSearchExpression>> *) searchExpressions;

@end

NS_ASSUME_NONNULL_END