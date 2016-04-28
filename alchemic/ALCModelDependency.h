//
//  ALCDependency.h
//  Alchemic
//
//  Created by Derek Clarkson on 4/02/2016.
//  Copyright © 2016 Derek Clarkson. All rights reserved.
//

@import Foundation;

#import "ALCDependency.h"

@class ALCModelSearchCriteria;
@class ALCInstantiation;

NS_ASSUME_NONNULL_BEGIN

@interface ALCModelDependency : NSObject<ALCDependency>

@property (nonatomic, strong, readonly) id searchResult;

-(instancetype) init NS_UNAVAILABLE;

-(instancetype) initWithObjectClass:(Class) objectClass
                           criteria:(ALCModelSearchCriteria *) criteria NS_DESIGNATED_INITIALIZER;

@end

NS_ASSUME_NONNULL_END

