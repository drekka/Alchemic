//
//  ALCClassInitializerBuilder.h
//  Alchemic
//
//  Created by Derek Clarkson on 22/07/2015.
//  Copyright © 2015 Derek Clarkson. All rights reserved.
//

#import "ALCAbstractMethodBuilder.h"

/**
 An ALCBuilder that can construct objects by using a specific initializer. 
 
 @discussion The initiailizer can have arguments and they must be matched by `AcArg(...)` macros.
 
 See AcInitializer(...) macro.
 */
@interface ALCClassInitializerBuilder : ALCAbstractMethodBuilder

@end
