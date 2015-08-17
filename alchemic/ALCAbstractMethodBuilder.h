//
//  ALCAbstractMethodBuilder.h
//  Alchemic
//
//  Created by Derek Clarkson on 22/07/2015.
//  Copyright © 2015 Derek Clarkson. All rights reserved.
//

#import "ALCAbstractBuilder.h"

@class ALCClassBuilder;
@protocol ALCBuilder;

NS_ASSUME_NONNULL_BEGIN

/**
 The abstract parent of ALCBuilder's that call a method to create the object.

 @discussion There are two types of method builders. ALCMethodBuilder which can build an object from a method call to an object. And ALCInitializerBuilder which is used to create objects by calling a specific initializer.
 */
@interface ALCAbstractMethodBuilder : ALCAbstractBuilder

/**
 The invocation that will be used to call the method.
 */
@property (nonatomic, strong, readonly) NSInvocation *inv;

/**
 Default initializer.

 @discussion Do not use.
 @return An instance of this class.
 */
-(instancetype) init NS_UNAVAILABLE;

/**
 Default initializer.

 @param parentClassBuilder A ALCClassBuilder which represents the class that the method belongs to.
 @param selector           The selector to call.

 @return An instance of this builder.
 */
-(instancetype) initWithParentClassBuilder:(ALCClassBuilder *) parentClassBuilder
                                  selector:(SEL) selector NS_DESIGNATED_INITIALIZER;

/**
 The parent class builder.
 */
@property (nonatomic, strong, readonly) ALCClassBuilder *parentClassBuilder;

-(id) instantiateObjectWithArguments:(NSArray<id> *) arguments;

/**
 Called to invoke the target selector on an object.

 @param target An object which contains the method to be executed.

 @return A value from the target method. It is assumed that there will always be a return value.
 */
-(id) invokeMethodOn:(id) target withArguments:(NSArray<id> *) arguments;

@end

NS_ASSUME_NONNULL_END
