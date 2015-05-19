//
//  ALCDependency.m
//  alchemic
//
//  Created by Derek Clarkson on 22/02/2015.
//  Copyright (c) 2015 Derek Clarkson. All rights reserved.
//

#import "ALCVariableDependency.h"
#import "ALCLogger.h"
#import "ALCRuntime.h"
#import "ALCResolvableObject.h"

#import "ALCClassMatcher.h"
#import "ALCProtocolMatcher.h"

@import ObjectiveC;

@implementation ALCVariableDependency {
    __weak ALCResolvableObject *_resolvableObject;
}

-(instancetype) initWithVariable:(Ivar) variable
              inResolvableObject:(__weak ALCResolvableObject *) resolvableObject
                        matchers:(NSSet *) dependencyMatchers {
    
    self = [super initWithMatchers:dependencyMatchers];
    if (self) {
        
        _resolvableObject = resolvableObject;
        _variable = variable;
        _variableProtocols = [[NSMutableArray alloc] init];
        
        [self loadVariableDetails];
        
        if (dependencyMatchers == nil) {
            logRegistration(@"Using variable declaration to define matchers");
            NSMutableSet *matchers = [[NSMutableSet alloc] init];
            if (_variableClass != nil) {
                [matchers addObject:[[ALCClassMatcher alloc] initWithClass:_variableClass]];
            }
            [_variableProtocols enumerateObjectsUsingBlock:^(Protocol *protocol, NSUInteger idx, BOOL *stop) {
                [matchers addObject:[[ALCProtocolMatcher alloc] initWithProtocol:protocol]];
            }];
            
            self.dependencyMatchers = matchers;
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

-(void) postProcess:(NSSet *)postProcessors {
    
    [super postProcess:postProcessors];
    
    // If there are no candidates left then error.
    if ([self.candidates count] == 0) {
        @throw [NSException exceptionWithName:@"AlchemicDependencyNotFound"
                                       reason:[NSString stringWithFormat:@"Unable to resolve dependency: %s::%s", class_getName(_resolvableObject.objectClass), ivar_getName(_variable)]
                                     userInfo:nil];
    }
    
}

-(NSString *) description {
    
    NSMutableArray *protocols = [[NSMutableArray alloc] initWithCapacity:[self.variableProtocols count]];
    [self.variableProtocols enumerateObjectsUsingBlock:^(Protocol *protocol, NSUInteger idx, BOOL *stop) {
        protocols[idx] = NSStringFromProtocol(protocol);
    }];
    
    const char *type = self.variableClass == nil ? "id" : class_getName(self.variableClass);
    return [NSString stringWithFormat:@"Variable %s::%s (%s<%@>)", class_getName(_resolvableObject.objectClass), ivar_getName(self.variable), type, [protocols componentsJoinedByString:@", "]];
    
}

@end
