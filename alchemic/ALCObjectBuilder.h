//
//  ALCObjectBuilder.h
//  alchemic
//
//  Created by Derek Clarkson on 23/08/2015.
//  Copyright © 2015 Derek Clarkson. All rights reserved.
//

@import Foundation;
#import "ALCBuilder.h"

/**
 Base builder for creating objects. 
 
 @discussion This class uses a variety of strategy classes to implement a variety of builder functions.
 */

@interface ALCObjectBuilder : NSObject<ALCBuilder>

@end
