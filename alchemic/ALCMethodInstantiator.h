//
//  ALCMethodInstantiator.h
//  alchemic
//
//  Created by Derek Clarkson on 25/08/2015.
//  Copyright © 2015 Derek Clarkson. All rights reserved.
//

@import Foundation;
#import "ALCInstantiator.h"
@protocol ALCBuilder;

/**
 Class that can create objects using a method.
 */
@interface ALCMethodInstantiator : NSObject<ALCInstantiator>

/**
 Unused.

 @return An instance of this class.
 */
-(instancetype) init NS_UNAVAILABLE;

/**
 Default initializer.

 @param classBuilder   The class builder that represents the class where the method resides.
 @param methodSelector The method selector to execute.

 @return An instance of this initiator.
 */
-(instancetype) initWithClassBuilder:(id<ALCBuilder>) classBuilder
                            selector:(SEL) methodSelector NS_DESIGNATED_INITIALIZER;

@end
