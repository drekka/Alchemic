//
//  ALCInjector.h
//  alchemic
//
//  Created by Derek Clarkson on 16/05/2016.
//  Copyright © 2016 Derek Clarkson. All rights reserved.
//

@import Foundation;
@import ObjectiveC;

#import "ALCResolvable.h"
#import "ALCDefs.h"

NS_ASSUME_NONNULL_BEGIN

@protocol ALCInjector <ALCResolvable>

-(ALCSimpleBlock) setObject:(id) object variable:(Ivar) variable;

-(void) setInvocation:(NSInvocation *) inv argumentIndex:(int) idx;

@end

NS_ASSUME_NONNULL_END
