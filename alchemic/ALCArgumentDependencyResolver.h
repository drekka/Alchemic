//
//  MethodArgumentDependency.h
//  alchemic
//
//  Created by Derek Clarkson on 11/05/2015.
//  Copyright (c) 2015 Derek Clarkson. All rights reserved.
//

@import Foundation;

#import "ALCDependencyResolver.h"
@class ALCFactoryMethod;

@interface ALCArgumentDependencyResolver : ALCDependencyResolver

-(instancetype) initWithFactoryMethod:(__weak ALCFactoryMethod *) factoryMethod
                        argumentIndex:(int) argumentIndex
                             matchers:(NSSet *) dependencyMatchers;

@end
