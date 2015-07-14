//
//  ALCObjectResolverFactory.h
//  alchemic
//
//  Created by Derek Clarkson on 17/05/2015.
//  Copyright (c) 2015 Derek Clarkson. All rights reserved.
//

@import Foundation;

@class ALCDependency;

/**
 Implementations take in a list of values and massage them according to the dependencies value class.
 */
@protocol ALCValueResolver <NSObject>

-(id) resolveValueForDependency:(ALCDependency *) dependency fromValues:(NSSet<id> *) objects;

@end
