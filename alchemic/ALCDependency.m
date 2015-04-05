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

#import <objc/runtime.h>
#import <objc/protocol.h>

@implementation ALCDependency

-(instancetype) initWithVariable:(Ivar) variable {
    self = [super init];
    if (self) {
        _variable = variable;
        _resolveUsingProtocols = [[NSMutableArray alloc] init];
        [self loadVariableDetails];
    }
    return self;
}

-(void) loadVariableDetails {
    
    // Get the type.
    const char *encoding = ivar_getTypeEncoding(_variable);
    NSString *variableTypeEncoding = [NSString stringWithCString:encoding encoding:NSUTF8StringEncoding];
    
    if ([variableTypeEncoding hasPrefix:@"@"]) {
        
        NSArray *defs = [variableTypeEncoding componentsSeparatedByCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@"@\",<>"]];
        
        // If there is no more than 2 in the array then the dependency is an id.
        for (int i = 2; i < [defs count]; i ++) {
            if ([defs[i] length] > 0) {
                if (i == 2) {
                    self.resolveUsingClass = objc_lookUpClass([defs[2] cStringUsingEncoding:NSUTF8StringEncoding]);
                } else {
                    [(NSMutableArray *)self.resolveUsingProtocols addObject:NSProtocolFromString(defs[i])];
                }
            }
        }
    }
}

-(void) setNewResolvingQualifiers:(NSArray *) qualifiers {
    
    // Clear current settings.
    self.resolveUsingName = nil;
    [(NSMutableArray *)self.resolveUsingProtocols removeAllObjects];
    self.resolveUsingClass = nil;
    
    // Loop through the new qualifiers and store them.
    [qualifiers enumerateObjectsUsingBlock:^(id qualifier, NSUInteger idx, BOOL *stop) {
        
        if ([qualifier isKindOfClass:[NSString class]]) {
            logRegistration(@"Resolve using name: %@", qualifier);
            self.resolveUsingName = qualifier;
        } else {
            // Test to see if it's a class.
            if (object_isClass(qualifier)) {
                
                Class classQualifier = qualifier;
                
                // Check for a Protocol.
                if ([@"Protocol" isEqualToString:NSStringFromClass(classQualifier)]) {
                    logRegistration(@"Resolve using protocol: %@", NSStringFromClass(classQualifier));
                    [(NSMutableArray *)self.resolveUsingProtocols addObject:classQualifier];
                } else {
                    logRegistration(@"Resolve using class: %@", qualifier);
                    self.resolveUsingClass = classQualifier;
                }
                return;
                
            }
            
            // It's not something we understand.
            @throw [NSException exceptionWithName:@"AlchemicUnknownQualifierType"
                                           reason:[NSString stringWithFormat:@"Unknown type of qualifier: %@", qualifier]
                                         userInfo:nil];

        }
    }];
    
}

-(void) resolveUsingResolvers:(NSArray *) resolvers {
    
    NSDictionary *candidates;
    for (id<ALCDependencyResolver> resolver in resolvers) {
        logDependencyResolving(@"Asking %s to resolve %s", class_getName([resolver class]), ivar_getName(_variable));
        candidates = [resolver resolveDependencyWithClass:self.resolveUsingClass
                                                protocols:self.resolveUsingProtocols
                                                     name:self.resolveUsingName];
        if (candidates != nil) {
            break;
        }
    }
    
    _candidateObjectDescriptions = candidates;
    if (_candidateObjectDescriptions == nil) {
        @throw [NSException exceptionWithName:@"AlchemicDependencyNotFound"
                                       reason:[NSString stringWithFormat:@"Unable to resolve dependency for: %s", ivar_getName(_variable)]
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
                                   reason:[NSString stringWithFormat:@"Unable to inject any candidateobjects for: %s", ivar_getName(_variable)]
                                 userInfo:nil];
    
}

@end
