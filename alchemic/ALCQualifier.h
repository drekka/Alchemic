//
//  Created by Derek Clarkson on 6/04/2015.
//  Copyright (c) 2015 Derek Clarkson. All rights reserved.
//

@import Foundation;
@protocol ALCBuilder;

NS_ASSUME_NONNULL_BEGIN

/**
 Wraps an argument so that it can be conveniantly passed around. 
 
 Usually arguments are classes, protocols or names.
 */
@interface ALCQualifier : NSObject

@property (nonatomic, strong, readonly) id value;

+(instancetype) qualifierWithValue:(id) value;

-(BOOL) isEqualToQualifier:(ALCQualifier *) qualifier;

@end

NS_ASSUME_NONNULL_END