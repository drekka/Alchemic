//
//  MethodArgumentDependency.h
//  alchemic
//
//  Created by Derek Clarkson on 11/05/2015.
//  Copyright (c) 2015 Derek Clarkson. All rights reserved.
//

@import Foundation;

#import "ALCDependency.h"
@class ALCResolvableMethod;

@interface ALCMethodArgumentDependency : ALCDependency

-(instancetype) initWithFactoryMethod:(__weak ALCResolvableMethod *) factoryMethod
                        argumentIndex:(int) argumentIndex
                             matchers:(NSSet *) dependencyMatchers;

@end
