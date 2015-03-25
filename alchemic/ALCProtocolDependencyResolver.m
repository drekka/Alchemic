//
//  ALCProtocolDependencyResolver.m
//  alchemic
//
//  Created by Derek Clarkson on 18/03/2015.
//  Copyright (c) 2015 Derek Clarkson. All rights reserved.
//

#import "ALCProtocolDependencyResolver.h"

#import <objc/runtime.h>

#import "ALCLogger.h"
#import "ALCObjectDescription.h"
#import "ALCContext.h"
#import "ALCDependency.h"
#import "ALCRuntime.h"
#import "NSDictionary+ALCModel.h"

@implementation ALCProtocolDependencyResolver

-(NSDictionary *) resolveDependency:(ALCDependency *) dependency {

    NSDictionary *objs;
    for (Protocol *protocol in dependency.variableProtocols) {
        objs = [objs objectDescriptionsWithProtocol:protocol];
        if ([objs count] == 0) {
            return nil;
        }
    }
    
    return objs;
}

@end
