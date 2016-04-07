//
//  NSSet+Alchemic.h
//  Alchemic
//
//  Created by Derek Clarkson on 7/04/2016.
//  Copyright © 2016 Derek Clarkson. All rights reserved.
//

@import Foundation;

NS_ASSUME_NONNULL_BEGIN

@interface NSSet (Alchemic)

+(void) unionSet:(nullable NSSet *) sourceSet intoMutableSet:(NSMutableSet  * _Nullable * _Nonnull) destSet;

@end

NS_ASSUME_NONNULL_END
