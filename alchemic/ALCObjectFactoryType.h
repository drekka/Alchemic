//
//  ALCObjectStorage.h
//  Alchemic
//
//  Created by Derek Clarkson on 30/01/2016.
//  Copyright © 2016 Derek Clarkson. All rights reserved.
//

@import Foundation;

#import <Alchemic/ALCObjectFactory.h>

NS_ASSUME_NONNULL_BEGIN

/**
 Protocol defining the public interface of classes that manage instantiated objects created by ALCObjectFactory instances.
 */
@protocol ALCObjectFactoryType<NSObject>

@property (nonatomic, assign, getter = isWeak) BOOL weak;

/**
 The currently stored object. With some ALCObjectFactoryType implementations this will always be nil. Others will store and return the object.
 */
@property (nonatomic, strong) id object;

/**
 Whether the ALCObjectFactoryType is ready. Ready is defined depending on the factoryType. For example, factories are always available where as reference types are only ready if they have a stored object.
 */
@property (nonatomic, assign, readonly) BOOL ready;

@end

NS_ASSUME_NONNULL_END
