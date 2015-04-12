//
//  ALCDependency.m
//  alchemic
//
//  Created by Derek Clarkson on 22/02/2015.
//  Copyright (c) 2015 Derek Clarkson. All rights reserved.
//

#import "ALCDependency.h"
#import "ALCLogger.h"
#import "ALCDependencyInjector.h"
#import "ALCRuntime.h"
#import "ALCInstance.h"

#import "ALCClassMatcher.h"
#import "ALCProtocolMatcher.h"

#import <objc/runtime.h>
#import <objc/protocol.h>

@implementation ALCDependency {
    NSArray *_dependencyMatchers;
}

-(instancetype) initWithVariable:(Ivar) variable matchers:(NSArray *) dependencyMatchers {
    self = [super init];
    if (self) {
        
        _variable = variable;
        _dependencyMatchers = dependencyMatchers;
        _variableProtocols = [[NSMutableArray alloc] init];
        _candidateObjectDescriptions = [[NSMutableArray alloc] init];
        
        [self loadVariableDetails];
        
        if (dependencyMatchers == nil) {
            logRegistration(@"Using variable declaration to define matchers");
            _dependencyMatchers = [[NSMutableArray alloc] init];
            if (_variableClass != nil) {
                [(NSMutableArray *)_dependencyMatchers addObject:[[ALCClassMatcher alloc] initWithClass:_variableClass]];
            }
            [_variableProtocols enumerateObjectsUsingBlock:^(Protocol *protocol, NSUInteger idx, BOOL *stop) {
                [(NSMutableArray *)_dependencyMatchers addObject:[[ALCProtocolMatcher alloc] initWithProtocol:protocol]];
            }];
        }
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
                    _variableClass = objc_lookUpClass([defs[2] cStringUsingEncoding:NSUTF8StringEncoding]);
                } else {
                    Protocol *protocol = NSProtocolFromString(defs[i]);
                    [(NSMutableArray *)_variableProtocols addObject:protocol];
                }
            }
        }
    }
}

-(void) resolveUsingModel:(NSDictionary *)model {
    
    logDependencyResolving(@"Searching for candidates for %s using %lu model objects", ivar_getName(_variable), [model count]);
    [model enumerateKeysAndObjectsUsingBlock:^(NSString *name, ALCInstance *instance, BOOL *Stop) {
        
        // Run matchers to see if they match. All must accept the candidate object.
        BOOL matched = YES;
        for (id<ALCMatcher> dependencyMatcher in _dependencyMatchers) {
            if (![dependencyMatcher matches:instance withName:name]) {
                matched = NO;
                break;
            }
        }
        
        if (matched) {
            logDependencyResolving(@"Adding '%@' %s to candidates", name, class_getName(instance.forClass));
            [(NSMutableArray *)_candidateObjectDescriptions addObject:instance];
        }
        
    }];
    
    // if there are no candidates left then error.
    if ([_candidateObjectDescriptions count] == 0) {
        @throw [NSException exceptionWithName:@"AlchemicDependencyNotFound"
                                       reason:[NSString stringWithFormat:@"Unable to resolve: %s", ivar_getName(_variable)]
                                     userInfo:nil];
    }
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
