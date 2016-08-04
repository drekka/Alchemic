//
//  ALCArgument.h
//  Alchemic
//
//  Created by Derek Clarkson on 22/03/2016.
//  Copyright © 2016 Derek Clarkson. All rights reserved.
//

@import Foundation;

#import <Alchemic/ALCAbstractDependency.h>
#import <Alchemic/ALCMethodArgumentDependencyInternal.h>

@protocol ALCDependency;
@protocol ALCModel;
@class ALCMethodArgumentDependency;

NS_ASSUME_NONNULL_BEGIN

/**
 Defines an argument for a method. 
 */
@interface ALCMethodArgumentDependency : ALCAbstractDependency <ALCMethodArgumentDependencyInternal>

/**
 The index of the argument for injecting into the executing NSInvocation.
 */
@property (nonatomic, assign) int index;

/**
 Unused initializer.
 @param injector -
 */
-(instancetype) initWithInjector:(id<ALCInjector>) injector NS_UNAVAILABLE;

/**
 Factory method for creating instances of ALCMethodArgumentDependency.
 
 @param argumentClass The class of the argument.
 @param firstCriteria A var arg list of criteria that define the value for the argument.
 @param ... further criteria.
 
 @return An instance of this class.
 */
+(instancetype) argumentWithClass:(Class) argumentClass criteria:(id) firstCriteria, ... NS_REQUIRES_NIL_TERMINATION;

@end

NS_ASSUME_NONNULL_END

