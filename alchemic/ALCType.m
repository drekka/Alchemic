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

-(instancetype) init {
    self = [super init];
    if (self) {
    }
    return self;
}

-(instancetype) initWithClass:(Class) class {
    self = [super init];
    if (self) {
        _typeProtocols = [[NSSet alloc] init];
        _typeClass = class;
    }
    return self;
}

+(instancetype) typeForClass:(Class) class {
    return [[ALCType alloc] initWithClass:class];
}

+(instancetype) typeForInjection:(Ivar) variable inClass:(Class) class {
    
    // Get the type.
    const char *encoding = ivar_getTypeEncoding(variable);
    NSString *variableTypeEncoding = [NSString stringWithCString:encoding encoding:NSUTF8StringEncoding];
    
    ALCType *info;
    if ([variableTypeEncoding hasPrefix:@"@"]) {
        
        // Object type.
        NSArray *defs = [variableTypeEncoding componentsSeparatedByCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@"@\",<>"]];
        
        // If there is no more than 2 in the array then the dependency is an id.
        for (NSUInteger i = 2; i < [defs count]; i ++) {
            if ([defs[i] length] > 0) {
                if (i == 2) {
                    Class class = objc_lookUpClass([defs[2] cStringUsingEncoding:NSUTF8StringEncoding]);
                    info = [[ALCType alloc] initWithClass:class];
                } else {
                    if (info == nil) {
                        info = [[ALCType alloc] initWithClass:NULL];
                    }
                    [info addProtocol:NSProtocolFromString(defs[i])];
                }
            }
        }
        
    } else {
        // Non object variable.
    }
    
    return info;
}

-(void) addProtocol:(Protocol *) protocol {
    _typeProtocols = [_typeProtocols setByAddingObject:protocol];
}

-(BOOL) typeIsKindOfClass:(Class)aClass {
    return _typeClass != NULL
    && [ALCRuntime class:_typeClass isKindOfClass:aClass];
}

-(BOOL) typeConformsToProtocol:(Protocol *)aProtocol {
    return [_typeClass conformsToProtocol:aProtocol] || [_typeProtocols containsObject:aProtocol];
}

@end
