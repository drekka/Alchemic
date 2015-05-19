//
//  MethodArgumentDependency.h
//  alchemic
//
//  Created by Derek Clarkson on 11/05/2015.
//  Copyright (c) 2015 Derek Clarkson. All rights reserved.
//

@import Foundation;

#import "ALCDependencyResolver.h"
@class ALCModelObjectFactoryMethod;

@interface ALCArgumentDependencyResolver : ALCDependencyResolver

-(instancetype) initWithFactoryMethod:(__weak ALCModelObjectFactoryMethod *) factoryMethod
                        argumentIndex:(int) argumentIndex
                             matchers:(NSSet *) dependencyMatchers;

@end
