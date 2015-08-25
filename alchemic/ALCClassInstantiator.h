//
//  ALCClassInstantiator.h
//  alchemic
//
//  Created by Derek Clarkson on 24/08/2015.
//  Copyright © 2015 Derek Clarkson. All rights reserved.
//

@import Foundation;
#import "ALCInstantiator.h"

/**
 Strategory for building objects defines simply as classes.
 */
@interface ALCClassInstantiator : NSObject<ALCInstantiator>

/**
 Not used

 @return An instance of this class.
 */
-(instancetype) init NS_UNAVAILABLE;

/**
 Default initializer.

 @discussion This instantiator makes use of the default init method to create an object.

 @param objectType The type of object that will be created.

 @return An instance of the instantiator.
 */
-(instancetype) initWithObjectType:(Class) objectType NS_DESIGNATED_INITIALIZER;

@end
