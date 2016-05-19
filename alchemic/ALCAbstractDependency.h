//
//  ALCAbstractDependencyDecorator.h
//  alchemic
//
//  Created by Derek Clarkson on 16/05/2016.
//  Copyright © 2016 Derek Clarkson. All rights reserved.
//

@import Foundation;

#import "ALCDependency.h"

@protocol ALCInjector;

NS_ASSUME_NONNULL_BEGIN

@interface ALCAbstractDependency : NSObject<ALCDependency>

@property(nonatomic, strong, readonly) id<ALCInjector> injector;

-(instancetype) init NS_UNAVAILABLE;

-(instancetype) initWithInjector:(id<ALCInjector>) injector NS_DESIGNATED_INITIALIZER;

@end

NS_ASSUME_NONNULL_END