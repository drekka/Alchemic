//
//  ALCDependencyInfo.m
//  alchemic
//
//  Created by Derek Clarkson on 22/02/2015.
//  Copyright (c) 2015 Derek Clarkson. All rights reserved.
//

#import "ALCDependencyInfo.h"
#import "ALCLogger.h"

@implementation ALCDependencyInfo

static NSCharacterSet *_objectTypeDelims;

-(instancetype) initWithVariable:(Ivar) variable inClass:(Class) inClass {
    self = [super init];
    if (self) {
        _objectTypeDelims = [NSCharacterSet characterSetWithCharactersInString:@"@\",<>"];
        _variable = variable;
        _inClass = inClass;
        _variableProtocols = [[NSMutableArray alloc] init];
        [self storeType];
    }
    return self;
}

-(void) storeType {
    // Get the type.
    const char *encoding = ivar_getTypeEncoding(_variable);
    _variableTypeEncoding = [NSString stringWithCString:encoding encoding:NSUTF8StringEncoding];
    logRegistration(@"Type encoding for %s::%s => %@", class_getName(_inClass), ivar_getName(_variable), _variableTypeEncoding);
    
    if ([_variableTypeEncoding hasPrefix:@"@"]) {
        
        NSArray *defs = [_variableTypeEncoding componentsSeparatedByCharactersInSet:_objectTypeDelims];
        
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

@end
