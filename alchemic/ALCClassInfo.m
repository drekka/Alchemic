//
//  ALCConstructorInfo.m
//  alchemic
//
//  Created by Derek Clarkson on 23/02/2015.
//  Copyright (c) 2015 Derek Clarkson. All rights reserved.
//

#import "ALCClassInfo.h"

@class ALCDependencyInfo;

@implementation ALCClassInfo {
    NSMutableArray *_dependencies;
}

-(instancetype) initWithClass:(Class) forClass name:(NSString *) name{
    self = [super init];
    if (self) {
        _forClass = forClass;
        _name = name;
        _dependencies = [[NSMutableArray alloc] init];
    }
    return self;
}

-(void) addDependency:(ALCDependencyInfo *)dependency {
    [(NSMutableArray *)_dependencies addObject:dependency];
}

-(void) resolveDependenciesUsingResolvers:(NSArray *) objectResolvers {
    
}

@end
