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
-(id) invokeSelector:(SEL) selector arguments:(nullable NSArray<id<ALCDependency>> *) arguments;

/**
 Executes a class method and returns the result.

 @param selector  The selector of the class method to execute.
 @param arguments The arguments required by the selector.
 @return the result from the method call. It is expected that the method will return a value.
 */
+(id) invokeSelector:(SEL) selector arguments:(nullable NSArray<id<ALCDependency>> *) arguments;

/**
 Used during model object resolving.

 This exists on NSObject as there is no common ancestor for classes that need to resolve. @see ALCClassObjectFactoryInitializer. It tells the object to resolve itself and any dependencies it may have.

 @param resolvingStack The current stack of resolving model objects.
 @param resolvedFlag   A reference to the variable within the class that indicates if it is currently resolving. This is used to detect circular references.
 @param block          A block which contains the class specific resolving code. Before this is executed, circular dependencies will be checked and the current model instance added to the stack.
 */
-(void) resolveWithStack:(NSMutableArray<id<ALCResolvable>> *) resolvingStack
            resolvedFlag:(BOOL *) resolvedFlag
                   block:(ALCSimpleBlock) block;

/**
 Sets a variable within an object.

 @param object   The object which contains the variable.
 @param variable The variable to be set.
 @param allowNil If YES, allows nil values to be passed and set. Otherwise throws an error if nil values or empty arrays are encountered when there should be values.
 @param value    The value to set.
 @param error A pointer to a NSError variable that will be set if an error occurs.
 @return YES if the variable was set.
 */

-(BOOL) setVariable:(Ivar) variable
             ofType:(Class) type
          allowNils:(BOOL) allowNil
              value:(nullable id) value
              error:(NSError * _Nullable *) error;

@end

NS_ASSUME_NONNULL_END
