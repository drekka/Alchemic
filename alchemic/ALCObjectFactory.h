//
//  ALCObjectFactory.h
//  alchemic
//
//  Created by Derek Clarkson on 26/01/2016.
//  Copyright © 2016 Derek Clarkson. All rights reserved.
//

@import Foundation;

#import "ALCInstantiator.h"

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSUInteger, ALCFactoryType) {
    ALCFactoryTypeSingleton,
    ALCFactoryTypeFactory,
    ALCFactoryTypeReference
};

@protocol ALCObjectFactory <ALCInstantiator>

@property (nonatomic, assign) ALCFactoryType factoryType;

@end

NS_ASSUME_NONNULL_END
