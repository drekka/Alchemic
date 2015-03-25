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
#import "ALCDependency.h"

@implementation NSMutableDictionary (ALCModel)

-(ALCObjectDescription *) objectDescriptionForClass:(Class) forClass name:(NSString *) name {
    ALCObjectDescription *description = self[name];
    if (description == nil) {
        logRegistration(@"Creating info for %@ (%s)", name, class_getName(forClass));
        description = [[ALCObjectDescription alloc] initWithClass:forClass name:name];
        self[name] = description;
    }
    return description;
}

-(void) registerInjection:(NSString *) inj inClass:(Class) class withName:(NSString *)name {
    ALCObjectDescription *description = [self objectDescriptionForClass:class name:name];
    Ivar variable = [ALCRuntime variableInClass:class forInjectionPoint:[inj UTF8String]];
    ALCDependency *dependency = [[ALCDependency alloc] initWithVariable:variable parentClass:class];
    logRegistration(@"Registering: %s::%s (%@)", class_getName(class), ivar_getName(variable), dependency.variableTypeEncoding);
    [description addDependency:dependency];
}

@end
