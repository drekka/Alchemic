//
//  STMatcher.h
//  StoryTeller
//
//  Created by Derek Clarkson on 25/06/2015.
//  Copyright © 2015 Derek Clarkson. All rights reserved.
//

@import Foundation;

@protocol STMatcher <NSObject>

-(BOOL) matches:(id __nonnull) key;

@property (nonatomic, strong, nullable) id<STMatcher> nextMatcher;

@end
