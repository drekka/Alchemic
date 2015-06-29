//
//  STScribe.h
//  StoryTeller
//
//  Created by Derek Clarkson on 18/06/2015.
//  Copyright © 2015 Derek Clarkson. All rights reserved.
//

@import Foundation;

/**
 Defines the public interface of classes which can act as loggers.
 */
@protocol STLogger <NSObject>

/**
 If @c YES, prints the log key on each line.
 */
@property (nonatomic, assign) BOOL showKey;

/**
 If @c YES, prints the thread id on each line.
 */
@property (nonatomic, assign) BOOL showThreadId;

/**
 If @c YES, prints the thread name on each line.
 */
@property (nonatomic, assign) BOOL showThreadName;

/**
 If @c YES, prints the current time on each line.
 */
@property (nonatomic, assign) BOOL showTime;

/**
 If @c YES, prints the class, method name and line number on each line.
 */
@property (nonatomic, assign) BOOL showMethodDetails;

/**
 Tells the logger to write the passed string.
 @discussion This is the main method to call in order to write to the log. The calling class is responsible for deciding whether to call this or not.
 @param message the string to be written to the output.
 @param methodName the name of the method which triggered this call.
 @param lineNumber the line number in the method which triggered this call.
 */
-(void) writeMessage:(NSString __nonnull *) message
          fromMethod:(const char __nonnull *) methodName
          lineNumber:(int) lineNumber
                 key:(id __nonnull) key;
@end
