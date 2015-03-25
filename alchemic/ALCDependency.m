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

@implementation ALCDependency {
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

-(void) resolveUsingResolvers:(NSArray *) resolvers {

    NSDictionary *candidates;
    for (id<ALCDependencyResolver> resolver in resolvers) {
        logDependencyResolving(@"Asking %s to resolve %s::%s", class_getName([resolver class]), class_getName(_parentClass), ivar_getName(_variable));
        candidates = [resolver resolveDependency:self];
        if (candidates != nil) {
            break;
        }
    }
    
    _candidateObjectDescriptions = candidates;
    if (_candidateObjectDescriptions == nil) {
        @throw [NSException exceptionWithName:@"AlchemicDependencyNotFound"
                                       reason:[NSString stringWithFormat:@"Unable to resolve dependency for: %s::%s", class_getName(_parentClass), ivar_getName(_variable)]
                                     userInfo:nil];
    }
    logDependencyResolving(@"Resolved dependency");

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
