//
//  ALCArgument.h
//  Alchemic
//
//  Created by Derek Clarkson on 14/07/2015.
//  Copyright © 2015 Derek Clarkson. All rights reserved.
//

@import Foundation;
@import ObjectiveC;
#import "ALCResolvable.h"
#import "ALCValue.h"

NS_ASSUME_NONNULL_BEGIN

@protocol ALCDependencyPostProcessor;

/**
 Objects that can produce values for dependencies.
 
 @discussion At the moment this is pretty much a placeholder protocol which doesn't do anything.
 */
@protocol ALCValueSource <ALCResolvable, ALCValue>

@end

NS_ASSUME_NONNULL_END