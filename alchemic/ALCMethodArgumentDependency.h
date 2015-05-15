//
//  MethodArgumentDependency.h
//  alchemic
//
//  Created by Derek Clarkson on 11/05/2015.
//  Copyright (c) 2015 Derek Clarkson. All rights reserved.
//

@import Foundation;

#import "ALCResolver.h"
#import "ALCFactoryMethod.h"

@interface ALCMethodArgumentDependency : ALCResolver

-(instancetype) initWithFactoryMethod:(__weak ALCFactoryMethod *) factoryMethod
                        argumentIndex:(int) argumentIndex
                             matchers:(NSSet *) dependencyMatchers;

@end
