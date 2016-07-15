//
//  ALCInjector.h
//  alchemic
//
//  Created by Derek Clarkson on 16/05/2016.
//  Copyright © 2016 Derek Clarkson. All rights reserved.
//

@import Foundation;
@import ObjectiveC;

#import <Alchemic/ALCResolvable.h>
#import <Alchemic/ALCTypeDefs.h>

NS_ASSUME_NONNULL_BEGIN

/**
 An injector is a class that can inject values into variables or method arguments.
 */
@protocol ALCInjector <ALCResolvable>

/**
 Injects a value into a variable.
 
 @param object   The object which contains the variable.
 @param variable The variable to inject.
 @result A simple block that can be called to execute objections.
 */
-(ALCSimpleBlock) setObject:(id) object variable:(Ivar) variable;

/**
 Injects a value into a method argument.
 
 @param inv The NSInvocation to set the value on.
 @param idx The index of the value. This is zero based with zero being the first argument to the selector.
 */
-(void) setInvocation:(NSInvocation *) inv argumentIndex:(int) idx;

/**
 When the value of this injector, the passed block will be called.
 
 @discussion This is only implemented on model object injectors. All other injectors do nothing. Again this is to help with taking a consistent protocol driven design.
 
 @param valueChangedBlock A block that will be called whenever a new value is set.
 
 */
-(void) watch:(void (^)(id _Nullable oldValue, id _Nullable newValue)) valueChangedBlock;

@end

NS_ASSUME_NONNULL_END
