//
//  STChronicleHook.h
//  StoryTeller
//
//  Created by Derek Clarkson on 19/06/2015.
//  Copyright © 2015 Derek Clarkson. All rights reserved.
//

@import Foundation;

/**
 Simple class that is designed to execute a block when a variable goes out of scope.
 @discussion To use it, do something like the following
 
 @code id hook = [[STDeallocHook alloc] initWithBlock:^{ \
 // Do something when 'hook' is dealloced \
 }];
 @endcode

 In Story Teller, @c STDeallocHook is used to detect when a @c startScope() macro should end the scope of the key. The hook simply calls @c StoryTeller::endScope:.
 */

@interface STDeallocHook : NSObject

/**
 Default initialiser.
 */
-(nonnull instancetype) initWithBlock:(__nonnull void (^)(void)) simpleBlock;

@end
