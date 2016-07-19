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

@protocol ALCObjectFactory;

NS_ASSUME_NONNULL_BEGIN

/**
 An injector is a class that can inject values into variables or method arguments.
 */
@protocol ALCInjector <ALCResolvable>

/// If YES, the injector can inject nil values. Otherwise it will throw an exception on encountering a nil.
@property (nonatomic, assign) BOOL allowNilValues;

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
 Returns YES if the passed object factory is referenced by this injector.
 
 @param objectFactory The object factroy to query for.
 */
-(BOOL) referencesObjectFactory:(id<ALCObjectFactory>) objectFactory;

@end

NS_ASSUME_NONNULL_END
