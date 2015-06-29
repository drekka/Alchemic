//
//  STFilterMatcher.h
//  StoryTeller
//
//  Created by Derek Clarkson on 26/06/2015.
//  Copyright © 2015 Derek Clarkson. All rights reserved.
//

@import Foundation;
#import "STMatcher.h"

@interface STFilterMatcher : NSObject<STMatcher>

@property (nonatomic, strong, nonnull) id<STMatcher> nextMatcher;

-(nonnull instancetype) initWithFilter:(__nullable id (^ __nonnull)(__nonnull id key)) filterBlock;

@end
