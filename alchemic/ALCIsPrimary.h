//
//  ALCIsPrimary.h
//  alchemic
//
//  Created by Derek Clarkson on 8/06/2015.
//  Copyright (c) 2015 Derek Clarkson. All rights reserved.
//

@import Foundation;
#import "ALCMacro.h"

/**
 A simple macro that represents objects which are primary objects.
 */
@interface ALCIsPrimary : NSObject<ALCMacro>

/**
 Returns a singleton instance of the macro.

 @return A singleton instance.
 */
+ (instancetype) primaryMacro;
@end
