//
//  ALCDependencyInfo.m
//  alchemic
//
//  Created by Derek Clarkson on 22/02/2015.
//  Copyright (c) 2015 Derek Clarkson. All rights reserved.
//

#import "ALCDependencyInfo.h"
#import "ALCLogger.h"

@implementation ALCDependencyInfo {
    NSMutableArray *_protocols;
}

-(instancetype) initWithVariable:(Ivar) variable parentClass:(Class) parentClass {
    self = [super init];
    if (self) {
        _parentClass = parentClass;
        _variable = variable;
        _protocols = [[NSMutableArray alloc] init];
        [self readVariableDetails];
    }
    return self;
}

-(void) readVariableDetails {
    
    // Get the type.
    const char *encoding = ivar_getTypeEncoding(_variable);
    _variableTypeEncoding = [NSString stringWithCString:encoding encoding:NSUTF8StringEncoding];
    logRegistration(@"Type encoding for %s::%s => %s", class_getName(_parentClass), ivar_getName(_variable), encoding);
    
    if ([_variableTypeEncoding hasPrefix:@"@"]) {
        
        NSArray *defs = [_variableTypeEncoding componentsSeparatedByCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@"@\",<>"]];
        
        // If there is no more than 2 in the array then the dependency is an id.
        if ([defs count] > 2) {
            
            // Grab the class name first.
            if ([defs[2] length] > 0) {
                _variableClass = objc_lookUpClass([defs[2] cStringUsingEncoding:NSUTF8StringEncoding]);
            }
            
            // Now any protocols.
            for (int i = 3; i < [defs count]; i++) {
                if ([defs[i] length] > 0) {
                    [(NSMutableArray *)_variableProtocols addObject:NSProtocolFromString(defs[i])];
                }
            }
        }
    }
    
}

-(void) setTargetClass:(ALCClassInfo *) targetClassInfo {
    logRegistration(@"Setting target class for dependency");
}

@end
