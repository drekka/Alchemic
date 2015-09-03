//
//  ALCMethodInstantiator.h
//  alchemic
//
//  Created by Derek Clarkson on 25/08/2015.
//  Copyright © 2015 Derek Clarkson. All rights reserved.
//

#import "ALCAbstractResolvable.h"
#import "ALCInstantiator.h"
#import "ALCinternalMacros.h"
@protocol ALCBuilder;

/**
 Class that can create objects using a method.
 */
@interface ALCMethodInstantiator : ALCAbstractResolvable<ALCInstantiator>

hideInitializer(init);

/**
 Default initializer.

 @param aClass      The class where the method resides.
 @param returnType  The class of the value that will be returned from the builder.
 @param initializer The method selector to execute.

 @return An instance of this initiator.
 */
-(instancetype) initWithClass:(Class) aClass
                           returnType:(Class) returnType
                             selector:(SEL) selector NS_DESIGNATED_INITIALIZER;

@end
