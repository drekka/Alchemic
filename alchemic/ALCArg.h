//
//  ACArg.h
//  Alchemic
//
//  Created by Derek Clarkson on 18/07/2015.
//  Copyright © 2015 Derek Clarkson. All rights reserved.
//

@import Foundation;

#import "ALCValueSourceFactory.h"
#import "ALCMacro.h"

@protocol ALCValueSource;

NS_ASSUME_NONNULL_BEGIN

/**
 Provides a wrapper around the information needed to define an argument to a selector.
 
 @discussion The `AcArg(...)` macro builds an instance of this class. It provides a return type and requires there to be at least one macro argument which defines the value for the argument.
 */
@interface ALCArg : ALCValueSourceFactory<ALCMacro>

/**
 Factorymethod used by `AcArg(...)`.

 @param argType The type of the argument. Used for matching when values have been sourced from the model.
 @param firstMacro The first macro argument which defines where to get the value for the method argument.
 @param ... A nil terminated list of macro arguments which give further definition to the data to be used for the method argument.
 @return An instance of this class.
 */
+(instancetype) argWithType:(Class) argType macros:(id<ALCMacro>) firstMacro, ... NS_REQUIRES_NIL_TERMINATION;

+(instancetype) argWithType:(Class) argType properties:(NSArray<id<ALCMacro>> *) properties;

@end

NS_ASSUME_NONNULL_END
