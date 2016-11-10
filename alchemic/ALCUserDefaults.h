//
//  ALCUSerDefaults.h
//  Alchemic
//
//  Created by Derek Clarkson on 22/8/16.
//  Copyright © 2016 Derek Clarkson. All rights reserved.
//

#import "ALCAbstractValueStore.h"

NS_ASSUME_NONNULL_BEGIN

/**
 The idea behind Alchemic's user defaults mechanism is to implement the reading of Root.plist files and redirect data to and from the standard user defaults.
 
 */
@interface ALCUserDefaults : ALCAbstractValueStore

@end

NS_ASSUME_NONNULL_END
