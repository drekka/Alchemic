//
//  ALCAbstractObjectFactory.h
//  alchemic
//
//  Created by Derek Clarkson on 26/01/2016.
//  Copyright © 2016 Derek Clarkson. All rights reserved.
//

@import Foundation;

#import "ALCObjectFactory.h"
#import "ALCDefs.h"

@class ALCInstantiation;
@protocol ALCModel;
@class ALCType;

NS_ASSUME_NONNULL_BEGIN

/**
 Abstract parent class of all object factories. 
 
 Defines core common processing used across the factories.
 */
@interface ALCAbstractObjectFactory : NSObject<ALCObjectFactory>

/**
 Unused initializer.
 */
-(instancetype) init NS_UNAVAILABLE;

/**
 Default initializer shared by implementations.
 
 @return An instance of the factory with default settings.
 */
-(instancetype) initWithType:(ALCType *) type NS_DESIGNATED_INITIALIZER;

/**
 Called to configure the factory beyond default settings.
 
 @param option              The configuration option being set.
 @param model A reference to the model in case the factory needs it.
 */
-(void) configureWithOption:(id) option model:(id<ALCModel>) model;

@end

NS_ASSUME_NONNULL_END
