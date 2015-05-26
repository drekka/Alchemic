//
//  ALCObjectBuilder.h
//  alchemic
//
//  Created by Derek Clarkson on 24/05/2015.
//  Copyright (c) 2015 Derek Clarkson. All rights reserved.
//

#import "ALCResolvable.h"

@protocol ALCBuilder <ALCResolvable>

@property (nonatomic, assign) BOOL primary;

@end
