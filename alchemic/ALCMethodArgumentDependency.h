//
//  ALCArgument.h
//  Alchemic
//
//  Created by Derek Clarkson on 22/03/2016.
//  Copyright © 2016 Derek Clarkson. All rights reserved.
//

@import Foundation;

#import "ALCAbstractDependency.h"

@class ALCType;

NS_ASSUME_NONNULL_BEGIN

/**
 Defines an argument for a method.
 */
@interface ALCMethodArgumentDependency : ALCAbstractDependency

@property (nonatomic, assign) NSUInteger index;

+(instancetype) methodArgumentWithType:(ALCType *) type criteria:firstCritieria, ... NS_REQUIRES_NIL_TERMINATION;

/**
 Mainly for internal use. 
 
 @param type     The type of the method's argument.
 @param criteria An NSArray of passed value criteria.

 @return <#return value description#>
 */
+(instancetype) methodArgumentWithType:(ALCType *) type argumentCriteria:(NSArray *) criteria;

@end

NS_ASSUME_NONNULL_END

