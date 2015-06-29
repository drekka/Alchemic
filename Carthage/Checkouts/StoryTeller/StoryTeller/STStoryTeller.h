//
//  StoryTeller.h
//  StoryTeller
//
//  Created by Derek Clarkson on 22/06/2015.
//  Copyright © 2015 Derek Clarkson. All rights reserved.
//

@import Foundation;

#import <StoryTeller/STLogger.h>

/**
 The main StoryTeller class.
 @discussion This class brings together all the configuration and processing for Story Teller. At the moment it's all in one class because it's not very big. Most of the functionality commonly needed is wrapped up in macros defined above.
 
 Story teller starts up as a singleton when the app loads. At that time it reads it's configuration and sets itself with default value. From that point on it can be accessed through the @c StoryTeller::storyTeller access point.
 */
@interface STStoryTeller : NSObject

/**
 Accessor for accessing the Story teller singleton instance. All interactions with Story Teller should go through this method.
 */
+(STStoryTeller __nonnull *) storyTeller;

/**
 Used mostly for debugging and testing.
 @discussion Generally speaking you would not need to reset the logging system.
 */
-(void) reset;

/**
 The current logger.
@discussion By defaul this is an instance of @c STConsoleLogger. However if you want, you can simple create and set a different class as long as it conforms to the @c STLogger protocol.
 @see STLogger
 */
@property (nonatomic, strong, nonnull) id<STLogger> logger;

@property (nonatomic, assign, readonly, getter=isLoggingAll) BOOL logAll;
@property (nonatomic, assign, readonly, getter=isLoggingRoots) BOOL logRoots;

/**
 Logs everything regardless of log settings.
 @discussion Again not something that would normally be turned on. But can be useful when debugging. Activating this will override any other logging settings.
 */
-(void) logAll;

/**
 Logs all top level log statements.

 @discussion Similar to @c logAll except that it only logs the top level log statements. Any statement which is inside an active Key Scope will be ignored. The main goal of this is to enable a semi-quick high level report of the data going through the app. Activating this will will override any logging criteria. But not logAll.
 */
-(void) logRoots;

#pragma mark - Activating logging

/**
 Start logging for the passed key.
 @param the key to log.
 */
-(void) startLogging:(NSString __nonnull *) keyExpression;

#pragma mark - Stories

/**
 Returns the number of Key Scopes that are currently active. 
 @discussion Usually used for debugging and testing of Story Teller itself.
 */
@property (nonatomic, assign, readonly) int numberActiveScopes;

/**
 Starts a key Scope. 
 @discussion the Key will basically group any @c log(...) statements that occur after it's definition and until it goes out of scope. Scope follows the Objective-C scope rules in that it finishes at the end of the current function, loop or if statement. Basically when a locally declared variable would be dealloced. 
 
 The major difference is that this scope also applies to any @c log(...) statements that are contained within methods called whilst the scope is active. This is the main purpose of this as it allows methods which do not have access to the key to be included in the logs when that key is being logged.
 
 @param key the key Scope to activate.
 */
-(void) startScope:(id __nonnull) key;

/**
 Removes a specific Key Scope.
 @discussion Normally you would not need to call this directly as @c StoryTeller::startScope: automatically removes the keys when the escope ends. In fact, by automatically calling this method.

 @param key the key Scope to de-activate.
*/
-(void) endScope:(id __nonnull) key;

/**
 Can be used to query if a Key Scope is active.
 @param key the key Scope to query.
 */
-(BOOL) isScopeActive:(id __nonnull) key;

#pragma mark - Logging

/**
 The main method to be called to log a message in the current logger.
 @discussion This method also handled the descision making around whether to pass the message onto the current logger or not. If going ahead, it assembles the final message and passes it to the logger.
 @param key the key to log the message under.
 @param methodName the name of the method where the @c log(...) statement occurs.
 @param lineNumber the line number in the method where the @c log(...) statement occurs.
 @param messageTemplate a standard @c NSString format message.
 @param vaList the arguments for the @c messageTemplate's placeholders.
 */
-(void) record:(id __nonnull) key method:(const char __nonnull *) methodName lineNumber:(int) lineNumber message:(NSString __nonnull *) messageTemplate, ...;

/**
 Useful helper method which executes a block of code if the key is active.
 @discussion Mainly used for wrapping up lines of code that involve more than just logging statements.
 @param block the block to execute. The @c key argument is the key that was checked.
 */
-(void) execute:(id __nonnull) key block:(__nonnull void (^)(id __nonnull key)) block;

@end

