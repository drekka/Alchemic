//
//  STMacros.h
//  StoryTeller
//
//  Created by Derek Clarkson on 24/06/2015.
//  Copyright © 2015 Derek Clarkson. All rights reserved.
//

#import <StoryTeller/STSToryTeller.h>
#import <StoryTeller/STDeallocHook.h>

#ifdef DISABLE_STORY_TELLER

// Remove all logging code.
#define startLogging(key)
#define startScope(key)
#define endScope(key)
#define log(key, messageTemplate, ...)
#define executeBlock(key, codeBlock)

#else

// Internal macro - don't use publically.
#define _ST_CONCAT(prefix, suffix) prefix ## suffix

// Concantiates the two values using another macro to do the work. This allows a level of indirection which
// means that macros such as __LINE__ can be concatinated.
#define ST_CONCATINATE(prefix, suffix) _ST_CONCAT(prefix, suffix)

#define startLogging(key) \
[[STStoryTeller storyTeller] startLogging:key]

#define startScope(key) \
_Pragma ("clang diagnostic push") \
_Pragma ("clang diagnostic ignored \"-Wunused-variable\"") \
NS_VALID_UNTIL_END_OF_SCOPE STDeallocHook *ST_CONCATINATE(_stHook_, __LINE__) = [[STDeallocHook alloc] initWithBlock:^{ \
endScope(key); \
}]; \
_Pragma ("clang diagnostic pop") \
[[STStoryTeller storyTeller] startScope:key]

#define endScope(key) \
[[STStoryTeller storyTeller] endScope:key]

#define log(key, messageTemplate, ...) \
[[STStoryTeller storyTeller] record:key method: __PRETTY_FUNCTION__ lineNumber: __LINE__ message:messageTemplate, ## __VA_ARGS__]

#define executeBlock(key, codeBlock) \
[[STStoryTeller storyTeller] execute:key block:codeBlock]

#endif
