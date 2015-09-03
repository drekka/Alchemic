//
//  ALCAbstractValueSource.h
//  Alchemic
//
//  Created by Derek Clarkson on 24/07/2015.
//  Copyright © 2015 Derek Clarkson. All rights reserved.
//

@import Foundation;
#import "ALCValueSource.h"
#import "ALCAbstractResolvable.h"
#import "ALCInternalMacros.h"

NS_ASSUME_NONNULL_BEGIN

/**
 Abstract parent class of all arguments.
 
 @discussion An argumnet is an object that can provide one or more values to satisfy a dependency.
 */
@interface ALCAbstractValueSource : ALCAbstractResolvable<ALCValueSource>

/**
 The values to be returned.

 @discussion This should be overridden to produce a set of one or more values. These will be further processed based on the argument type.

 @return A NSSet containing zero or more values.
 */
@property (nonatomic, strong, readonly) NSSet<id> *values;

hideInitializer(init);

/**
 Default initializer

 @param argumentType The expected type of the argument. This is used when deciding what to return from resolving.

 @return And instance of this class.
 */
-(instancetype) initWithType:(Class) argumentType NS_DESIGNATED_INITIALIZER;

@end

NS_ASSUME_NONNULL_END
