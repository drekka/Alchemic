//
//  ALCObjectStandIn.m
//  alchemic
//
//  Created by Derek Clarkson on 27/02/2015.
//  Copyright (c) 2015 Derek Clarkson. All rights reserved.
//

#import "ALCDependencyFault.h"

@implementation ALCDependencyFault

- (void)forwardInvocation:(NSInvocation *)invocation {
    
}

- (NSMethodSignature *)methodSignatureForSelector:(SEL)sel {
    return nil;
}

-(void) faultIn {
    
}

@end
