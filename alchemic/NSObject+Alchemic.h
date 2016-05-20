//
//  NSObject+Alchemic.h
//  Alchemic
//
//  Created by Derek Clarkson on 7/02/2016.
//  Copyright © 2016 Derek Clarkson. All rights reserved.
//

@import Foundation;
@import ObjectiveC;

#import <Alchemic/ALCTypeDefs.h>

@protocol ALCDependency;
@protocol ALCModel;
@protocol ALCResolvable;

NS_ASSUME_NONNULL_BEGIN

/**
 NSObject extensions.
 */
@interface NSObject (Alchemic)

/**
 Executes an instance method and returns the result.
 
 @param selector  The selector of the instance method to execute.
 @param arguments The arguments required by the selector.
 @return the result from the method call. It is expected that the method will return a value.
 */
-(id) invokeSelector:(SEL) selector arguments:(NSArray<id<ALCDependency>> *) arguments;

/**
 Executes a class method and returns the result.
 
 @param selector  The selector of the class method to execute.
 @param arguments The arguments required by the selector.
 @return the result from the method call. It is expected that the method will return a value.
 */
+(id) invokeSelector:(SEL) selector arguments:(NSArray<id<ALCDependency>> *) arguments;

/**
 Used during model object resolving.
 
 This exists on NSObject as there is no common ancestor for classes that need to resolve. @see ALCClassObjectFactoryInitializer. It tells the object to resolve itself and any dependencies it may have.
 
 @param resolvingStack The current stack of resolving model objects.
 @param resolvedFlag   A reference to the variable within the class that indicates if it is currently resolving. This is used to detect circular references.
 @param block          A block which contains the class specific resolving code. Before this is executed, circular dependencies will be checked and the current model instance added to the stack.
 */
-(void) resolveWithResolvingStack:(NSMutableArray<id<ALCResolvable>> *) resolvingStack
                     resolvedFlag:(BOOL *) resolvedFlag
                            block:(ALCSimpleBlock) block;

@end

NS_ASSUME_NONNULL_END