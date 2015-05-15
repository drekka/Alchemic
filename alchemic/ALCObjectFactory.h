//
//  ALCObjectFactory.h
//  alchemic
//
//  Created by Derek Clarkson on 22/02/2015.
//  Copyright (c) 2015 Derek Clarkson. All rights reserved.
//

@import Foundation;

@class ALCObjectInstance;
@class ALCContext;

/**
 Any class that is capable of creating objects.
 */
@protocol ALCObjectFactory <NSObject>

/**
 Called when the context needs an object to be created.
 
 @param classInfo the information tha describes the object to be created.
 @return an instance of the object or null if the factory cannot create the object.
 */
-(id) createObjectFromInstance:(ALCObjectInstance *) instance;

@end
