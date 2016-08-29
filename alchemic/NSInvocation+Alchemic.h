//
//  NSInvocation+Alchemic.h
//  Alchemic
//
//  Created by Derek Clarkson on 18/8/16.
//  Copyright © 2016 Derek Clarkson. All rights reserved.
//

@import Foundation;

NS_ASSUME_NONNULL_BEGIN

@interface NSInvocation (Alchemic)

/**
 Sets an argument in a passed invocation.

 @param idx        The index of the argument. This is zero based with 0 being the first argument to the method.
 @param value      The value to set.
 @param allowNil If YES, allows nil values to be passed and set. Otherwise throws an error if nil values or empty arrays are encountered when there should be values.
 @param type The type of the value to be set. This is used when assess if the passed value needs to be wrapped further before being passed to the invocation.
 @return YES if the argument was set.
 */
-(BOOL) setArgIndex:(int) idx
             ofType:(Class) type
          allowNils:(BOOL) allowNil
              value:(nullable id) value
              error:(NSError * __autoreleasing _Nullable *) error;

@end

NS_ASSUME_NONNULL_END
