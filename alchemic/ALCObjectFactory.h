//
//  ALCObjectFactory.h
//  alchemic
//
//  Created by Derek Clarkson on 22/02/2015.
//  Copyright (c) 2015 Derek Clarkson. All rights reserved.
//

@import Foundation;

#import "ALCClassInfo.h"

/**
 Any class that is capable of creating objects.
 */
@protocol ALCObjectFactory <NSObject>

-(id) createObjectFromClassInfo:(ALCClassInfo *) classInfo;

@end
