//
//  ALCNameDependencyResolver.m
//  alchemic
//
//  Created by Derek Clarkson on 27/03/2015.
//  Copyright (c) 2015 Derek Clarkson. All rights reserved.
//

#import "ALCNameDependencyResolver.h"

@implementation ALCNameDependencyResolver

-(NSDictionary *) resolveDependencyWithClass:(Class) aClass
                                   protocols:(NSArray *) protocols
                                        name:(NSString *) name {
    return self.model[name];
}

@end
