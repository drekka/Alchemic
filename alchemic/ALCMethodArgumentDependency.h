//
//  ALCArgument.h
//  Alchemic
//
//  Created by Derek Clarkson on 22/03/2016.
//  Copyright © 2016 Derek Clarkson. All rights reserved.
//

@import Foundation;

#import <Alchemic/ALCAbstractDependency.h>

@class ALCType;

NS_ASSUME_NONNULL_BEGIN

/**
 Defines an argument for a method.
 */
@interface ALCMethodArgumentDependency : ALCAbstractDependency

@property (nonatomic, assign) NSUInteger index;

+(instancetype) methodArgumentWithType:(ALCType *) type criteria:firstCritieria, ... NS_REQUIRES_NIL_TERMINATION;

@end

NS_ASSUME_NONNULL_END

