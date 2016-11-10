//
//  ALCAbstractDependencyDecorator.h
//  alchemic
//
//  Created by Derek Clarkson on 16/05/2016.
//  Copyright © 2016 Derek Clarkson. All rights reserved.
//

@import Foundation;

#import "ALCDependency.h"

@class ALCType;
@class ALCValue;
@protocol ALCValueSource;

NS_ASSUME_NONNULL_BEGIN

/**
 Abstract parent class of dependency classes.
 
 Provides common implementations of methods.
 */
@interface ALCAbstractDependency : NSObject<ALCDependency>

@property (nonatomic, strong, readonly) id<ALCValueSource> valueSource;

/**
 Unavailable initializer.
 */
-(instancetype) init NS_UNAVAILABLE;

/**
 Default initializer.
 
 @param type The type to beinjected.
 @param valueSource Where the value for the injection is to come from.
 
 @return An instance of this class.
 */
-(instancetype) initWithType:(ALCType *) type
                 valueSource:(id<ALCValueSource>) valueSource;

+(instancetype) dependencyWithType:(ALCType *) type
                       valueSource:(id<ALCValueSource>) valueSource;

-(void) configureWithOptions:(NSArray *) options NS_REQUIRES_SUPER;

@end

NS_ASSUME_NONNULL_END
