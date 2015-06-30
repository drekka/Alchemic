//
//  ALCResolverPostProcessor.h
//  alchemic
//
//  Created by Derek Clarkson on 29/04/2015.
//  Copyright (c) 2015 Derek Clarkson. All rights reserved.
//

@import Foundation;
@class ALCDependency;

@protocol ALCDependencyPostProcessor <NSObject>

/**
 @return a new list of candidates objects or nil if the list is not changed.
 */
-(NSSet *) process:(NSSet *) dependencies;

@end