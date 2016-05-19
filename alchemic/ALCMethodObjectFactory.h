//
//  ALCMethodObjectFactory.h
//  Alchemic
//
//  Created by Derek Clarkson on 12/02/2016.
//  Copyright © 2016 Derek Clarkson. All rights reserved.
//

#import "ALCAbstractObjectFactory.h"
@class ALCClassObjectFactory;
@protocol ALCDependency;

NS_ASSUME_NONNULL_BEGIN

/**
 A factory that creates objects by calling methods on a class.
 
 Methods can be either class methods or instance methods. If instance methods then the parent class will be instantiated as necessary so that the methods can be called.
 
 Unlike variable injections, methods must have all of their arguments fully created and completed before injection. This is done because we cannot tell what the code within the method will do, and therefore do not know what it might need from the arguments.
 */
@interface ALCMethodObjectFactory : ALCAbstractObjectFactory

/**
 Unavailable initializer.
 @param objectClass -
 */
-(instancetype) initWithClass:(Class)objectClass NS_UNAVAILABLE;

/**
 Default initializer.
 
 @param objectClass         The class of the object that will be returned from the methods.
 @param parentObjectFactory A reference to a ALCClassObjectFactory that represents the parent class of the method.
 @param selector            The selector to execute.
 @param arguments           A NSArray of ALCDependency instances which will be used to inject values into the method call.
 
 @return An instance of this factory.
 */
-(instancetype) initWithClass:(Class)objectClass
          parentObjectFactory:(ALCClassObjectFactory *) parentObjectFactory
                     selector:(SEL) selector
                         args:(nullable NSArray<id<ALCDependency>> *) arguments NS_DESIGNATED_INITIALIZER;

@end

NS_ASSUME_NONNULL_END
