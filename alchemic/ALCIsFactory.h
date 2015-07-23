//
//  IsSngleton.h
//  alchemic
//
//  Created by Derek Clarkson on 7/06/2015.
//  Copyright (c) 2015 Derek Clarkson. All rights reserved.
//

@import Foundation;
#import "ALCMacro.h"

/**
 Used to tag registrations that are for factories. Ie. every time they are accessed, they create a new instance of the desired object.
 */

@interface ALCIsFactory : NSObject<ALCMacro>

@end
