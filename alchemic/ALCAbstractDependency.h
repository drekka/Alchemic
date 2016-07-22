//
//  ALCAbstractDependencyDecorator.h
//  alchemic
//
//  Created by Derek Clarkson on 16/05/2016.
//  Copyright © 2016 Derek Clarkson. All rights reserved.
//

@import Foundation;

#import <Alchemic/ALCDependency.h>

@protocol ALCInjector;

NS_ASSUME_NONNULL_BEGIN

/**
 Abstract parent class of dependency classes.
 
 Provides common implementations of methods.
 */
@interface ALCAbstractDependency : NSObject<ALCDependency>

/**
 The ALCInjector instance that will be used by the dependency.
 */
@property(nonatomic, strong, readonly) id<ALCInjector> injector;

/**
 Unavailable initializer.
 */
-(instancetype) init NS_UNAVAILABLE;

/**
 Default initializer.
 
 Takes and injector which will be used by the dependency to source the value to be injected.
 
 @param injector The injector to be used by the dependency.
 
 @return An instance of this class.
 */
-(instancetype) initWithInjector:(id<ALCInjector>) injector NS_DESIGNATED_INITIALIZER;

@end

NS_ASSUME_NONNULL_END