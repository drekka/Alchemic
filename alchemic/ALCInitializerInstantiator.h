//
//  ALCInitializerInstantiator.h
//  alchemic
//
//  Created by Derek Clarkson on 25/08/2015.
//  Copyright © 2015 Derek Clarkson. All rights reserved.
//

#import "ALCAbstractInstantiator.h"

/**
 Creates an object using a custom initializer.
 */
@interface ALCInitializerInstantiator : ALCAbstractInstantiator

/**
 Do not use.

 @return An instance of the instantiator.
 */
-(instancetype) init NS_UNAVAILABLE;

/**
 Default initializer.

 @param aClass      The class to instantiate.
 @param initializer The method selector to execute.

 @return An instance of this initiator.
 */
-(instancetype) initWithClass:(Class) aClass
                  initializer:(SEL) initializer NS_DESIGNATED_INITIALIZER;

@end
