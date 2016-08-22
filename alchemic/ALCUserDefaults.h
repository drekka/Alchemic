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
 
 */
@interface ALCUserDefaults : NSObject<AlchemicAware>

@end
