//
//  ALCAbstractValueSource.h
//  Alchemic
//
//  Created by Derek Clarkson on 24/07/2015.
//  Copyright © 2015 Derek Clarkson. All rights reserved.
//

@import Foundation;
#import "ALCValueSource.h"

NS_ASSUME_NONNULL_BEGIN

/**
 Abstract parent class of all value sources. 
 
 @discussion A value source is an object that can provide one or more values to satisfy a dependency.
 */
@interface ALCAbstractValueSource : NSObject<ALCValueSource>

/**
 The values.

 @return A NSSet containing zero or more values.
 */
-(NSSet<id> *) values;

@end

NS_ASSUME_NONNULL_END
