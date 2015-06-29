//
//  STAbstractScribe.h
//  StoryTeller
//
//  Created by Derek Clarkson on 18/06/2015.
//  Copyright © 2015 Derek Clarkson. All rights reserved.
//

@import Foundation;
#import <StoryTeller/STLogger.h>

/**
 An abstract class that implements the core logic for formatting and writing text to output destinations.
 */
@interface STAbstractLogger : NSObject<STLogger>

/**
 Writes the passed text to the output.
 @discussion This method @b MUST be overridden.
 */
-(void) writeMessage:(NSString __nonnull *) message;

@end
