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

@implementation ALCProtocolDependencyResolver

-(NSArray *) resolveDependency:(ALCDependencyInfo *) dependency inObject:(id) object {
    
    Ivar variable = dependency.variable;
    logObjectResolving(@"Resolving %s", ivar_getName(variable));
    
    if ([dependency.variableProtocols count] == 0) {
        logObjectResolving(@"No protocol found on variable %s", ivar_getName(variable));
        return nil;
    }
    
    return nil;
//    return [ALCRuntime filterObjects:self.model forProtocols:dependency.variableProtocols];
}

@end
