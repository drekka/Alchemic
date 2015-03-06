//
//  ALCObjectStandIn.m
//  alchemic
//
//  Created by Derek Clarkson on 27/02/2015.
//  Copyright (c) 2015 Derek Clarkson. All rights reserved.
//

#import "ALCLazyDependency.h"

#import <objc/runtime.h>

@implementation ALCLazyDependency {
    ALCDependencyInfo *_dependencyInfo;
}

-(instancetype) initWithDependencyInfo:(ALCDependencyInfo *) dependencyInfo {
    _dependencyInfo = dependencyInfo;
    return self;
}

+(Class) class {
    return [NSString class];
}

- (void)forwardInvocation:(NSInvocation *)invocation {
}

- (NSMethodSignature *)methodSignatureForSelector:(SEL)sel {
    return nil;
}

@end
