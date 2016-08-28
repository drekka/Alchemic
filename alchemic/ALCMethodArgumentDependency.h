//
//  ALCArgument.h
//  Alchemic
//
//  Created by Derek Clarkson on 22/03/2016.
//  Copyright © 2016 Derek Clarkson. All rights reserved.
//

@import Foundation;

#import <Alchemic/ALCAbstractDependency.h>

@protocol ALCDependency;
@protocol ALCModel;
@class ALCMethodArgumentDependency;

NS_ASSUME_NONNULL_BEGIN

/**
 Defines an argument for a method.
 */
@interface ALCMethodArgumentDependency : ALCAbstractDependency

@property (nonatomic, assign) NSUInteger index;

@end

NS_ASSUME_NONNULL_END

