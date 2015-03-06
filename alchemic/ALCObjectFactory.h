//
//  ALCObjectFactory.h
//  alchemic
//
//  Created by Derek Clarkson on 22/02/2015.
//  Copyright (c) 2015 Derek Clarkson. All rights reserved.
//

@import Foundation;

@class ALCClassInfo;
@class ALCContext;

/**
 Any class that is capable of creating objects.
 */
@protocol ALCObjectFactory <NSObject>

/**
 Default initialiser
 
 @param context the ALCContext that owns the factory.
 
 @return an instance of the factory.
 */
-(instancetype) initWithContext:(ALCContext *) context;

/**
 Called when the context needs an object to be created.
 
 @param classInfo the information tha describes the object to be created.
 @return an instance of the object or null if the factory cannot create the object.
 */
-(id) createObjectFromClassInfo:(ALCClassInfo *) classInfo;

@end
