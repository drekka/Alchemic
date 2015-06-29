//
//  InMemoryScribe.h
//  StoryTeller
//
//  Created by Derek Clarkson on 18/06/2015.
//  Copyright © 2015 Derek Clarkson. All rights reserved.
//

@import Foundation;

#import <StoryTeller/StoryTeller.h>

@interface InMemoryLogger : STAbstractLogger

@property (nonatomic, strong, readonly, nonnull) NSArray *log;

@end
