//
//  ALCUserDefaultsAspect.h
//  Alchemic
//
//  Created by Derek Clarkson on 23/8/16.
//  Copyright © 2016 Derek Clarkson. All rights reserved.
//

@import Foundation;

#import "ALCAbstractAspect.h"

/**
 Aspect which manages the creation of user default handling classes. If the user has not defined any class derived from ALCUserDefaults, 
 this aspect will set ALCUserDefaults as the default user defaults handler.
 
 Otherwise a class can be declared which extends ALCUserDefaults. All that needs to be added are properties. The parent ALCUserDetails will take care of loading Root.plist and saving changes to the system user defaults.
 */

@interface ALCUserDefaultsAspect : ALCAbstractAspect

@end
