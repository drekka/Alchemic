//
//  ALCObjectBuilder+ClassBuilder.h
//  alchemic
//
//  Created by Derek Clarkson on 25/08/2015.
//  Copyright © 2015 Derek Clarkson. All rights reserved.
//

#import "ALCObjectBuilder.h"

/**
 Methods relevant to class builders only.
 */
@interface ALCObjectBuilder (ClassBuilder)

/**
 Adds a variable injection to the builder.

 @discussion This is used to register variable dependencies which are injected int0 created objects.

 @param variable       The name of the variable or property to be injected.
 */
-(void) addVariableInjection:(Ivar) variable
                 valueSource:(id<ALCValueSource>) valueSource;

/**
 Used to manually populate dependencies in an object not created by Alchemic.

 @param object The object which needs dependencies injected.
 */
-(void)injectDependencies:(id) object;

@end
