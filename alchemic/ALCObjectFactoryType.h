//
//  ALCObjectStorage.h
//  Alchemic
//
//  Created by Derek Clarkson on 30/01/2016.
//  Copyright © 2016 Derek Clarkson. All rights reserved.
//

@import Foundation;

#import "ALCObjectFactory.h"

NS_ASSUME_NONNULL_BEGIN

/**
 @brief Protocol defining the public interface of classes that manage instantiated objects created by ALCObjectFactory instances.
 */
@protocol ALCObjectFactoryType<NSObject>

/**
 @brief The type of the factory.
 */
@property (nonatomic, assign, readonly) ALCFactoryType factoryType;

/**
 @brief The currently stored object. With some ALCObjectFactoryType implementations this will always be nil. Others will store and return the object.
 */
@property (nonatomic, strong) id object;

/**
 @brief Whether the ALCObjectFactoryType is ready. Ready is defined depending on the factoryType. For example, factories are always available where as reference types are only ready if they have a stored object.
 */
@property (nonatomic, assign, readonly) BOOL ready;

@end

NS_ASSUME_NONNULL_END
