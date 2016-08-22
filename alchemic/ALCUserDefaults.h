//
//  ALCUSerDefaults.h
//  Alchemic
//
//  Created by Derek Clarkson on 22/8/16.
//  Copyright © 2016 Derek Clarkson. All rights reserved.
//

@import Foundation;
#import <Alchemic/AlchemicAware.h>

/**
 The idea behind Alchemic's user default is to implement the reading of Root.plist files and redirect data to and from the standard user defaults. 
 
 Optionally the developer can write an extension of this class and simple populate it with properties which will be automatically intercepted and stored in the user defaults.
 */
@interface ALCUserDefaults : NSUserDefaults<AlchemicAware>

@end
