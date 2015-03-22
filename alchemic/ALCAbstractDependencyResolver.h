//
//  ALCAbstractDependencyResolver.h
//  alchemic
//
//  Created by Derek Clarkson on 17/03/2015.
//  Copyright (c) 2015 Derek Clarkson. All rights reserved.
//

@import Foundation;

#import "ALCDependencyResolver.h"

@interface ALCAbstractDependencyResolver : NSMutableDictionary<ALCDependencyResolver>

@property (nonatomic, weak, readonly) NSDictionary *model;

@end
