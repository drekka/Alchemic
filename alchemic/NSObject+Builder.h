//
//  NSObject+Alchemic.h
//  alchemic
//
//  Created by Derek Clarkson on 15/08/2015.
//  Copyright © 2015 Derek Clarkson. All rights reserved.
//

@import Foundation;

// Must import or Generics don't resolve.
#import "ALCVariableDependency.h"

/**
 Extension to NSObject.
 */
@interface NSObject (Alchemic)

/**
 Executes the specified selector and returns the result.

 @param selector  The selector to execute.
 @param arguments The arguments required by the selector.

 @return The value generated by the method.
 */
-(id) invokeSelector:(SEL) selector arguments:(NSArray *) arguments;

/**
 Injects an object with dependencies.

 @param object The object to be injected.
 */
-(void) injectWithDependencies:(NSSet<ALCVariableDependency *> *) dependencies;

/// @name Injecting

/**
 Sets the value of an internal variable in an object.

 @param variable The variable to be set.
 @param value The value to set.
 */
-(void) injectVariable:(Ivar) variable withValue:(id) value;

@end
