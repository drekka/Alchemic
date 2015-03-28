//
//  ALCDependency.m
//  alchemic
//
//  Created by Derek Clarkson on 22/02/2015.
//  Copyright (c) 2015 Derek Clarkson. All rights reserved.
//

#import "ALCDependency.h"
#import "ALCLogger.h"
#import "ALCDependencyResolver.h"
#import "ALCDependencyInjector.h"

@implementation ALCDependency

-(instancetype) initWithVariable:(Ivar) variable qualifier:(NSString *) qualifier parentClass:(Class) parentClass {
    self = [super init];
    if (self) {
        _parentClass = parentClass;
        _variableQualifier = qualifier;
        _variable = variable;
        _variableProtocols = [[NSMutableArray alloc] init];
        [self readVariableDetails];
    }
    return self;
}

-(void) readVariableDetails {
    
    // Get the type.
    const char *encoding = ivar_getTypeEncoding(_variable);
    _variableTypeEncoding = [NSString stringWithCString:encoding encoding:NSUTF8StringEncoding];
    
    if ([_variableTypeEncoding hasPrefix:@"@"]) {
        
        NSArray *defs = [_variableTypeEncoding componentsSeparatedByCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@"@\",<>"]];
        
        // If there is no more than 2 in the array then the dependency is an id.
        for (int i = 2; i < [defs count]; i ++) {
            if ([defs[i] length] > 0) {
                if (i == 2) {
                    _variableClass = objc_lookUpClass([defs[2] cStringUsingEncoding:NSUTF8StringEncoding]);
                } else {
                    [(NSMutableArray *)_variableProtocols addObject:NSProtocolFromString(defs[i])];
                }
            }
        }
    }
    
}

-(void) injectObject:(id) finalObject usingInjectors:(NSArray *) injectors {
    for (id<ALCDependencyInjector> injector in injectors) {
        if ([injector injectObject:finalObject dependency:self]) {
            return;
        }
    }

    @throw [NSException exceptionWithName:@"AlchemicValueNotInjected"
                                   reason:[NSString stringWithFormat:@"Unable to inject any candidateobjects for: %s::%s", class_getName(_parentClass), ivar_getName(_variable)]
                                 userInfo:nil];

}

@end
