//
//  ALCMatcher.h
//  alchemic
//
//  Created by Derek Clarkson on 6/04/2015.
//  Copyright (c) 2015 Derek Clarkson. All rights reserved.
//

@import Foundation;
@class ALCInstance;

/**
 Implement to define a matcher for selectinign injections.
 */
@protocol ALCMatcher <NSObject>

/**
 Return YES if the instance being examined is matched by the matcher.
 */
-(BOOL) matches:(ALCInstance *) instance withName:(NSString *) name;

@end
