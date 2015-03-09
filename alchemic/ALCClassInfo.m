//
//  ALCConstructorInfo.m
//  alchemic
//
//  Created by Derek Clarkson on 23/02/2015.
//  Copyright (c) 2015 Derek Clarkson. All rights reserved.
//

#import "ALCClassInfo.h"

@class ALCDependencyInfo;

@implementation ALCClassInfo

-(instancetype) initWithClass:(Class) forClass {
    self = [super init];
    if (self) {
        _forClass = forClass;
        _dependencies = @[];
        self.constructor = @selector(init);
    }
    return self;
}

-(void) addDependency:(ALCDependencyInfo *)dependency {
    _dependencies = [_dependencies arrayByAddingObject:dependency];
}


@end
