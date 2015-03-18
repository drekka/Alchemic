//
//  AlchemicAware.h
//  alchemic
//
//  Created by Derek Clarkson on 17/03/2015.
//  Copyright (c) 2015 Derek Clarkson. All rights reserved.
//

@import Foundation;

/**
 Implement this protocol if you need to be aware of Alchemics life cycle.
 */
@protocol AlchemicAware <NSObject>

/**
 Called after all dependencies have been resolved.
 */
-(void) didResolveDependencies;

@end
