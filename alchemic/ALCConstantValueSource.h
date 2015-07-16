//
//  ALCConstantValueSource.h
//  Alchemic
//
//  Created by Derek Clarkson on 16/07/2015.
//  Copyright © 2015 Derek Clarkson. All rights reserved.
//

@import Foundation;
#import "ALCValueSource.h"

NS_ASSUME_NONNULL_BEGIN

@interface ALCConstantValueSource : NSObject<ALCValueSource>

-(instancetype) initWithValue:(id) value;

@end

NS_ASSUME_NONNULL_END