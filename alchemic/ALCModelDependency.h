//
//  ALCDependency.h
//  Alchemic
//
//  Created by Derek Clarkson on 4/02/2016.
//  Copyright © 2016 Derek Clarkson. All rights reserved.
//

@import Foundation;
@class ALCModelSearchCriteria;

#import "ALCResolvable.h"

NS_ASSUME_NONNULL_BEGIN

@interface ALCModelDependency : NSObject<ALCResolvable>

-(instancetype) initWithCriteria:(ALCModelSearchCriteria *) criteria;

@end

NS_ASSUME_NONNULL_END

