//
//  ALCClassInstantiator.h
//  alchemic
//
//  Created by Derek Clarkson on 24/08/2015.
//  Copyright © 2015 Derek Clarkson. All rights reserved.
//

@import Foundation;
#import "ALCAbstractResolvable.h"
#import "ALCInternalMacros.h"
#import "ALCInstantiator.h"

/**
 Strategory for building objects defines simply as classes.
 */
@interface ALCClassInstantiator : ALCAbstractResolvable<ALCInstantiator>

hideInitializer(init);

/**
 Default initializer.

 @param aClass The class of the object this instantiator will create.

 @return An instance of this class.
 */
-(instancetype) initWithClass:(Class) aClass NS_DESIGNATED_INITIALIZER;

@end
