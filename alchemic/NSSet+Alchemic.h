//
//  NSSet+Alchemic.h
//  alchemic
//
//  Created by Derek Clarkson on 13/08/2015.
//  Copyright © 2015 Derek Clarkson. All rights reserved.
//

@import Foundation;

NS_ASSUME_NONNULL_BEGIN

/**
 Utilities for a NSSet.
 */
@interface NSSet (Alchemic)

/**
 Provides the same functionality as [NSString componentsJoinedByString:].

 @param delimiter The delimiter to insert between each component.

 @return A string with all the compoents concatinated.
 */
-(NSString *) componentsJoinedByString:(NSString *) delimiter;

/**
 Joines the descriptions of all the items in the set together using the template to format each one.

 @param delimiter         The delimter to insert between each item.
 @param componentTemplate The template to format the item. This must have only 1 occurance of '%@' in it which is where the item's description will be inserted.

 @return A NSString composed of all the items in the set concatinated together.
 */
-(NSString *) componentsJoinedByString:(NSString *) delimiter withTemplate:(NSString *) componentTemplate;

@end

NS_ASSUME_NONNULL_END