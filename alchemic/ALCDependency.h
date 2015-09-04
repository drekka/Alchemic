//
//  ALCResolver.h
//  alchemic
//
//  Created by Derek Clarkson on 17/04/2015.
//  Copyright (c) 2015 Derek Clarkson. All rights reserved.
//

@import Foundation;

@protocol ALCDependencyPostProcessor;
@protocol ALCValueSource;
#import "ALCValue.h"
#import "ALCInternalMacros.h"

NS_ASSUME_NONNULL_BEGIN

/**
 Represents a single dependency of a variable or method argument.
 
 @discussion ALCDependency objects are the core link between a ALCBuilder and the values it needs. A builder will define a dependency for any variables it needs (in the case of ALCBuilder) or method arguments. Each ALCDependency contains a class reference representing the type of object that will be set and a ALCArgument instance that defines where to get it from.
 */
@interface ALCDependency : NSObject<ALCValue>

/**
 The value source that will provide the value for the dependency.
 */
@property (nonatomic, strong, readonly) id<ALCValueSource> valueSource;

hideInitializer(init);

/**
 Default initializer.

 @param valueSource An ALCArgument instance which can source the value.

 @return An instance of this class.
 */
-(instancetype) initWithValueSource:(id<ALCValueSource>) valueSource NS_DESIGNATED_INITIALIZER;

@end

NS_ASSUME_NONNULL_END