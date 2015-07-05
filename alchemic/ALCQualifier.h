//
//  Created by Derek Clarkson on 6/04/2015.
//  Copyright (c) 2015 Derek Clarkson. All rights reserved.
//

@import Foundation;

/**
 Wraps an argument so that it can be conveniantly passed around. 
 
 Usually arguments are classes, protocols or names.
 */
@interface ALCQualifier : NSObject

@property (nonatomic, strong, readonly, nonnull) id value;

+(nonnull instancetype) qualifierWithValue:(id __nonnull) value;

@end
