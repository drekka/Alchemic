//
//  STConfig.h
//  StoryTeller
//
//  Created by Derek Clarkson on 22/06/2015.
//  Copyright © 2015 Derek Clarkson. All rights reserved.
//

@import Foundation;
@class STStoryTeller;

/**
 Reads and configures @c StoryTeller with config data from a variety of places.
 @discussion Story Teller's configuration starts with a hard wired internal setup. This is then overlaid with any settings from the @cStoryTellerConfig.json file (if it exists). After that, arguments passed to the process are checked and loaded. This give the developer the ability to provide settings via XCode schemes.
 */
@interface STConfig : NSObject

/**
 After loading, configures the passed instance of @c StoryTeller.
 @param storyTeller the instance to configure.
 */
-(void) configure:(STStoryTeller __nonnull *) storyTeller;

@end
