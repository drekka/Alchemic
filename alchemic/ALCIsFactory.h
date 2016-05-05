//
//  IsSngleton.h
//  alchemic
//
//  Created by Derek Clarkson on 7/06/2015.
//  Copyright (c) 2015 Derek Clarkson. All rights reserved.
//

@import Foundation;

/**
 When passed to a factory registration, sets the factory to be a factory.

 @discussion Factories create a new instance of an object every time they are accessed.

 @param _objectName the name to set on the registration.
 */
#define AcFactory [ALCIsFactory factoryMacro]

/**
 Used to tag registrations that are for factories. Ie. every time they are accessed, they create a new instance of the desired object.
 */

@interface ALCIsFactory : NSObject

/**
 Returns a singleton instance of the macro.

 @return A singleton instance.
 */
+(ALCIsFactory *) factoryMacro;

@end
