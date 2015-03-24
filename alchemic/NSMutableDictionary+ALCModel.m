//
//  NSDictionary+ALCModel.m
//  alchemic
//
//  Created by Derek Clarkson on 23/03/2015.
//  Copyright (c) 2015 Derek Clarkson. All rights reserved.
//

#import "NSMutableDictionary+ALCModel.h"

#import <objc/runtime.h>
#import "ALCLogger.h"
#import "ALCRuntime.h"
#import "ALCDependencyInfo.h"

@implementation NSMutableDictionary (ALCModel)

-(ALCClassInfo *) infoForClass:(Class) forClass name:(NSString *) name {
    ALCClassInfo *info = self[name];
    if (info == nil) {
        logRegistration(@"Creating info for %@ (%s)", name, class_getName(forClass));
        info = [[ALCClassInfo alloc] initWithClass:forClass name:name];
        self[name] = info;
    }
    return info;
}

-(void) registerInjection:(NSString *) inj inClass:(Class) class withName:(NSString *)name {
    ALCClassInfo *info = [self infoForClass:class name:name];
    Ivar variable = [ALCRuntime variableInClass:class forInjectionPoint:[inj UTF8String]];
    ALCDependencyInfo *dependencyInfo = [[ALCDependencyInfo alloc] initWithVariable:variable parentClass:class];
    logRegistration(@"Registering: %s::%s (%@)", class_getName(class), ivar_getName(variable), dependencyInfo.variableTypeEncoding);
    [info addDependency:dependencyInfo];
}

@end
