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
 
 @param objectClass the class of the object that the factory will create or manage.
 
 @return An instance of the factory with default settings.
 */
-(instancetype) initWithClass:(Class) objectClass NS_DESIGNATED_INITIALIZER;

/**
 Called to configure the factory beyond default settings.
 
 @param option              The configuration option being set.
 @param model A reference to the model in case the factory needs it.
 */
-(void) configureWithOption:(id) option model:(id<ALCModel>) model;

/**
 Sets the observer to execute a block when a change to a dependency is detected.
 */
-(void) setDependencyUpdateObserverWithBlock:(void (^) (NSNotification *)) watchBlock;

@end

NS_ASSUME_NONNULL_END
