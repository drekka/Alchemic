//
//  ALCObjectFactory.h
//  alchemic
//
//  Created by Derek Clarkson on 26/01/2016.
//  Copyright © 2016 Derek Clarkson. All rights reserved.
//

@import Foundation;

#import "ALCInstantiator.h"

@class ALCInstantiation;
@protocol ALCContext;

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSUInteger, ALCFactoryType) {
    ALCFactoryTypeSingleton,
    ALCFactoryTypeFactory,
    ALCFactoryTypeReference
};

@protocol ALCObjectFactory <ALCInstantiator>

@property (nonatomic, assign, readonly) ALCFactoryType factoryType;

@property (nonatomic, assign, readonly) BOOL primary;

-(void) configureWithOptions:(NSArray *) options customOptionHandler:(void (^)(id option)) customOptionHandler;

@property (nonatomic, strong, readonly) ALCInstantiation *instantiation;

@end

NS_ASSUME_NONNULL_END
