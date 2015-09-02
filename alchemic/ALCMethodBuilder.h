//
//  ALCMethodBuilder.h
//  alchemic
//
//  Created by Derek Clarkson on 1/09/2015.
//  Copyright © 2015 Derek Clarkson. All rights reserved.
//

#import "ALCAbstractBuilder.h"
@class ALCClassBuilder;

NS_ASSUME_NONNULL_BEGIN

@interface ALCMethodBuilder : ALCAbstractBuilder

/**
 Do not use.

 @param instantiator     An instance of ALCInstantiator which implements the code which builds objects and injects them with dependencies.
 @param forClass         The class of the object that the builder will create.

 @return An instance of a ALCBuilder.
 */

-(instancetype) initWithInstantiator:(id<ALCInstantiator>) instantiator
                            forClass:(Class) aClass NS_UNAVAILABLE;

/**
 default initializer.

 @param instantiator     An instance of ALCInstantiator which implements the code which builds objects and injects them with dependencies.
 @param forClass         The class of the object that the builder will create.

 @return An instance of a ALCBuilder.
 */

-(instancetype) initWithInstantiator:(id<ALCInstantiator>) instantiator
                            forClass:(Class) aClass
                       parentBuilder:(ALCClassBuilder *) parentBuilder NS_DESIGNATED_INITIALIZER;

/**
 Call to directory access the builder using a custom set of values.

 @param arguments An NSarray of the values matching the methods arguments.

 @return The return object from the method with all dependencies injected.
 */
-(id) invokeWithArgs:(NSArray *) arguments;

@end

NS_ASSUME_NONNULL_END