//
//  ALCClassInfo.m
//  alchemic
//
//  Created by Derek Clarkson on 21/05/2015.
//  Copyright (c) 2015 Derek Clarkson. All rights reserved.
//

#import "ALCType.h"
#import "ALCRuntime.h"

@implementation ALCType

-(nonnull instancetype) init {
    self = [super init];
    if (self) {
        _typeProtocols = [[NSSet alloc] init];
        _typeClass = NULL;
    }
    return self;
}

+(nonnull instancetype) typeForClass:(Class __nonnull) class {
    ALCType *type = [[ALCType alloc] init];
    type.typeClass = class;
    return type;
}

+(nonnull instancetype) typeForInjection:(Ivar __nonnull) variable inClass:(Class __nonnull) class {

    // Get the type.
    const char *encoding = ivar_getTypeEncoding(variable);
    NSString *variableTypeEncoding = [NSString stringWithCString:encoding encoding:NSUTF8StringEncoding];

    ALCType *info;
    if ([variableTypeEncoding hasPrefix:@"@"]) {

        // Object type.
        NSArray *defs = [variableTypeEncoding componentsSeparatedByCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@"@\",<>"]];

        // If there is no more than 2 in the array then the dependency is an id.
        info = [[ALCType alloc] init];
        for (NSUInteger i = 2; i < [defs count]; i ++) {
            if ([defs[i] length] > 0) {
                if (i == 2) {
                    Class depClass = objc_lookUpClass([defs[2] cStringUsingEncoding:NSUTF8StringEncoding]);
                    info.typeClass = depClass;
                } else {
                    [info addProtocol:NSProtocolFromString(defs[i])];
                }
            }
        }

    } else {
        // Non object variable.
    }

    return info;
}

-(void) addProtocol:(Protocol __nonnull *) protocol {
    _typeProtocols = [_typeProtocols setByAddingObject:protocol];
}

-(BOOL) typeIsKindOfClass:(Class __nonnull) aClass {
    return _typeClass != NULL
    && [ALCRuntime class:_typeClass isKindOfClass:aClass];
}

-(BOOL) typeConformsToProtocol:(Protocol __nonnull *) aProtocol {
    return [_typeClass conformsToProtocol:aProtocol] || [_typeProtocols containsObject:aProtocol];
}

@end
