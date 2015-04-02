//
//  ALCNameDependencyResolver.m
//  alchemic
//
//  Created by Derek Clarkson on 27/03/2015.
//  Copyright (c) 2015 Derek Clarkson. All rights reserved.
//

#import "ALCNameDependencyResolver.h"
#import "ALCInstance.h"

@implementation ALCNameDependencyResolver

-(NSDictionary *) resolveDependencyWithClass:(Class) aClass
                                   protocols:(NSArray *) protocols
                                        name:(NSString *) name {
    ALCInstance * instance = self.model[name];
    return instance == nil ? nil : @{name: instance};
}

@end
