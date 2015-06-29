//
//  STExpressionMatcherFactory.h
//  StoryTeller
//
//  Created by Derek Clarkson on 25/06/2015.
//  Copyright © 2015 Derek Clarkson. All rights reserved.
//

@import Foundation;

@class STStoryTeller;
#import "STLogExpressionParserDelegate.h"
#import "STMatcher.h"

@interface STExpressionMatcherFactory : NSObject<STLogExpressionParserDelegate>

-(nullable id<STMatcher>) parseExpression:(NSString __nonnull *) expression
                                    error:(NSError *__autoreleasing  __nullable * __nullable) error;

@end
