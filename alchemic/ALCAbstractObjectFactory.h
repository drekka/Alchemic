//
//  ALCAbstractObjectFactory.h
//  alchemic
//
//  Created by Derek Clarkson on 26/01/2016.
//  Copyright © 2016 Derek Clarkson. All rights reserved.
//

@import Foundation;

#import <Alchemic/ALCObjectFactory.h>
#import <Alchemic/ALCDefs.h>

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

-(void) setDependencyUpdateObserverWithBlock:(void (^) (NSNotification *)) watchBlock;

/**
 Sets an object into the factory. 
 
 @discussion This is only legal for singleton or reference class factories. Any factory that involves a method such as method factories and class factories with initializers will reject having a value set.

 This method is for calling from the main context. It forwards to the storeObject: method and then sends notifications to dependencies that are listen for changes.

 @param object The object to store.
 
 @return the completion block that can be called to perform injections into the stored object.
 */
-(void) setObject:(id) object;

/**
 Stores an object in the factory.

 This is only legal for singleton or reference class factories. Any factory that involves a method such as method factories and class factories with initializers will reject having a value set.

 @param object The object to store.

 @return the completion block that can be called to perform injections into the stored object.
 */
//-(ALCBlockWithObject) storeObject:(id) object;

@end

NS_ASSUME_NONNULL_END
