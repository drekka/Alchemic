//
//  ALCDependency.h
//  Alchemic
//
//  Created by Derek Clarkson on 21/02/2016.
//  Copyright © 2016 Derek Clarkson. All rights reserved.
//

@import Foundation;
@import ObjectiveC;

#import "ALCDefs.h"
#import "ALCResolvable.h"

@protocol ALCModel;

NS_ASSUME_NONNULL_BEGIN

@protocol ALCDependency <ALCResolvable>

-(ALCSimpleBlock) setObject:(id) object variable:(Ivar) variable;

-(void) setInvocation:(NSInvocation *) inv argumentIndex:(int) idx;

@end

NS_ASSUME_NONNULL_END
