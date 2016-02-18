//
//  NSObject+Alchemic.h
//  Alchemic
//
//  Created by Derek Clarkson on 7/02/2016.
//  Copyright © 2016 Derek Clarkson. All rights reserved.
//

@import Foundation;
@import ObjectiveC;
@protocol ALCResolvable;

@interface NSObject (Alchemic)

-(void) injectVariable:(Ivar) variable withResolvable:(id<ALCResolvable>) resolvable;

/**
 Executes the specified selector and returns the result.

 @param selector  The selector to execute.
 @param arguments The arguments required by the selector.

 @return The value generated by the method.
 */
-(id) invokeSelector:(SEL) selector arguments:(NSArray *) arguments;

/**
 Executes the specified selector and returns the result.

 @param selector  The selector to execute.
 @param arguments The arguments required by the selector.

 @return The value generated by the method.
 */
+(id) invokeSelector:(SEL) selector arguments:(NSArray *) arguments;

@end
