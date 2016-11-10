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
@class ALCType;

NS_ASSUME_NONNULL_BEGIN

/**
 A factory that creates objects by calling methods on a class.

 Methods can be either class methods or instance methods. If instance methods then the parent class will be instantiated as necessary so that the methods can be called.

 Unlike variable injections, methods must have all of their arguments fully created and completed before injection. This is done because we cannot tell what the code within the method will do, and therefore do not know what it might need from the arguments.
 */
@interface ALCMethodObjectFactory : ALCAbstractObjectFactory

/**
 The parent object factory that represents the class where the method resides.
 */
@property (nonatomic, strong, readonly) ALCClassObjectFactory *parentObjectFactory;

/**
 The selector that will be called.
 */
@property (nonatomic, assign, readonly) SEL selector;

/**
 Unavailable initializer.
 @param type -
 */
-(instancetype) initWithType:(ALCType *) type NS_UNAVAILABLE;

/**
 Default initializer.

 @param parentObjectFactory A reference to a ALCClassObjectFactory that represents the parent class of the method.
 @param selector            The selector to execute.
 @param arguments           A NSArray of ALCDependency instances which will be used to inject values into the method call.

 @return An instance of this factory.
 */
-(instancetype) initWithType:(ALCType *) type
         parentObjectFactory:(ALCClassObjectFactory *) parentObjectFactory
                    selector:(SEL) selector
                        args:(nullable NSArray<id<ALCDependency>> *) arguments NS_DESIGNATED_INITIALIZER;

@end

NS_ASSUME_NONNULL_END
