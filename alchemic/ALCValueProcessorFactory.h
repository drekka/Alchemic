//
//  ALCObjectResolverFactory.h
//  alchemic
//
//  Created by Derek Clarkson on 17/05/2015.
//  Copyright (c) 2015 Derek Clarkson. All rights reserved.
//

@import Foundation;

#import "ALCValueProcessor.h"
#import "ALCDependency.h"

/**
 A factory for find the particular object resolver for a dependency.
 */
@protocol ALCValueProcessorFactory <NSObject>

-(id<ALCValueProcessor>) valueProcessorForDependency:(ALCDependency *) dependency;

@end
