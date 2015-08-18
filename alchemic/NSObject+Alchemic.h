//
//  NSObject+Alchemic.h
//  alchemic
//
//  Created by Derek Clarkson on 15/08/2015.
//  Copyright © 2015 Derek Clarkson. All rights reserved.
//

@import Foundation;

/**
 Extension to NSObject.
 */
@interface NSObject (Alchemic)

/**
 Executes the specified selector.

 @param selector  The selector to execute.
 @param arguments The arguments required by the selector.

 @return <#return value description#>
 */
-(id) invokeSelector:(SEL) selector arguments:(NSArray *) arguments;

@end
