//
//  ALCInitializerInstantiator.h
//  alchemic
//
//  Created by Derek Clarkson on 25/08/2015.
//  Copyright © 2015 Derek Clarkson. All rights reserved.
//

@import Foundation;
#import "ALCInstantiator.h"
@protocol ALCBuilder;

/**
 Creates an object using a custom initializer.
 */
@interface ALCInitializerInstantiator : NSObject<ALCInstantiator>

/**
 Unused.

 @return An instance of this class.
 */
-(instancetype) init NS_UNAVAILABLE;

/**
 Default initializer.

 @param classBuilder   The class builder that represents the class where the initializer resides.
 @param initializerSelector The initializer selector to execute.

 @return An instance of this initiator.
 */
-(instancetype) initWithClassBuilder:(id<ALCBuilder>) classBuilder
                         initializer:(SEL) initializerSelector NS_DESIGNATED_INITIALIZER;


@end
