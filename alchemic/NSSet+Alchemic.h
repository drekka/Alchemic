//
//  NSSet+Alchemic.h
//  Alchemic
//
//  Created by Derek Clarkson on 7/04/2016.
//  Copyright © 2016 Derek Clarkson. All rights reserved.
//

@import Foundation;

NS_ASSUME_NONNULL_BEGIN

/**
 Extensions to NSSet.
 */
@interface NSSet (Alchemic)

/**
 Unions two NSSets, accounting for either one being nil. The results of the union will be set into the destSet variable reference.
 
 @param sourceSet The left NSSet.
 @param destSet   A reference to the variable where the right NSSet can be found. If this is nil the variable will be set to the left set.
 */
+(void) unionSet:(nullable NSSet *) sourceSet intoMutableSet:(NSMutableSet  * _Nullable * _Nonnull) destSet;

@end

NS_ASSUME_NONNULL_END
