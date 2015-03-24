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
#import "ALCClassInfo.h"
#import "ALCContext.h"
#import "ALCDependencyInfo.h"
#import "ALCRuntime.h"
#import "NSDictionary+ALCModel.h"

@implementation ALCProtocolDependencyResolver

-(NSDictionary *) resolveDependency:(ALCDependencyInfo *) dependency {

    NSDictionary *objs;
    for (Protocol *protocol in dependency.variableProtocols) {
        objs = [objs infoObjectsWithProtocol:protocol];
        if ([objs count] == 0) {
            return nil;
        }
    }
    
    return objs;
}

@end
