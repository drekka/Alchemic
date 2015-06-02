//
//  ALCObjectBuilder.h
//  alchemic
//
//  Created by Derek Clarkson on 24/05/2015.
//  Copyright (c) 2015 Derek Clarkson. All rights reserved.
//

#import "ALCResolvable.h"

@class ALCDependency;

@protocol ALCBuilder <ALCResolvable>

@property (nonatomic, assign) BOOL primary;

@property (nonatomic, assign) BOOL factory;

@property (nonatomic, assign) BOOL singleton;

-(void) addDependency:(ALCDependency *) dependency;

@end
