//
//  ALCIsExternal.h
//  alchemic
//
//  Created by Derek Clarkson on 25/08/2015.
//  Copyright © 2015 Derek Clarkson. All rights reserved.
//

@import Foundation;
#import "ALCMacro.h"

/**
 Tag macro that indicates that the source of objects is external to Alchemic.
 */
@interface ALCIsExternal : NSObject<ALCMacro>

/**
 Returns a singleton instance of the macro.

 @return A singleton instance.
 */
+ (instancetype) externalMacro;

@end
