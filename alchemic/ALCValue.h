//
//  ALCValue.h
//  alchemic
//
//  Created by Derek Clarkson on 25/08/2015.
//  Copyright © 2015 Derek Clarkson. All rights reserved.
//

@import Foundation;

NS_ASSUME_NONNULL_BEGIN

/**
 Classes that can provide values to other classes.
 */
@protocol ALCValue <NSObject>

/**
 The value.
 */
@property (nonatomic, strong, readonly) id value;

/**
 The class of the object that will be returned from the resolvable.
 */
@property (nonatomic, strong, readonly) Class valueClass;

@end

NS_ASSUME_NONNULL_END