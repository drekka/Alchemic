//
//  ALCObjectBuilder+MethodBuilder.h
//  alchemic
//
//  Created by Derek Clarkson on 25/08/2015.
//  Copyright © 2015 Derek Clarkson. All rights reserved.
//

#import "ALCObjectBuilder.h"

/**
 Methods relevant to method builders only.
 */
@interface ALCObjectBuilder (MethodBuilder)

/**
 Manually executes a method builder passing a custom set of arguments.

 @param arguments The arguments to pass to the method.

 @return The object created by the method.
 */
-(id) invokeWithArgs:(NSArray *) arguments;

@end
