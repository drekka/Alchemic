//
//  ALCObjectFactory.h
//  alchemic
//
//  Created by Derek Clarkson on 26/01/2016.
//  Copyright © 2016 Derek Clarkson. All rights reserved.
//

@import Foundation;

#import "ALCResolvable.h"

@protocol ALCModel;
@class ALCModelDependency;

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSUInteger, ALCFactoryType) {
    ACLFactoryTypeSingleton,
    ALCFactoryTypeFactory,
    ALCFactoryTypeReference
};

@protocol ALCObjectFactory <ALCResolvable>

@property (nonatomic, strong, readonly) NSString *defaultName;

@property (nonatomic, assign) ALCFactoryType factoryType;

-(instancetype) initWithClass:(Class) valueClass;

-(void) registerDependency:(id<ALCResolvable>) dependency forVariable:(NSString *) variableName;

-(void) injectDependenciesIntoObject:(id) value;

@end

NS_ASSUME_NONNULL_END