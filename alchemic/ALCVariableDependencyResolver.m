//
//  ALCDependency.m
//  alchemic
//
//  Created by Derek Clarkson on 22/02/2015.
//  Copyright (c) 2015 Derek Clarkson. All rights reserved.
//

#import "ALCVariableDependencyResolver.h"
#import "ALCLogger.h"
#import "ALCAbstractObjectResolver.h"
#import "ALCRuntime.h"
#import "ALCObjectInstance.h"

#import "ALCClassMatcher.h"
#import "ALCProtocolMatcher.h"

@import ObjectiveC;

@implementation ALCVariableDependencyResolver {
    __weak ALCObjectInstance *_instance;
}

-(instancetype) initWithVariable:(Ivar) variable inModelObject:(__weak ALCObjectInstance *) modelObject matchers:(NSSet *) dependencyMatchers {

    self = [super initWithMatchers:dependencyMatchers];
    if (self) {

        _instance = modelObject;
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

-(void) injectObject:(id) object usingInjectors:(NSArray *) injectors {
    for (id<ALCObjectResolver> injector in injectors) {
        if ([injector injectObject:object dependency:self]) {
            return;
        }
    }
}

-(void) postProcess:(NSSet *)postProcessors {
    
    [super postProcess:postProcessors];

    // If there are no candidates left then error.
    if ([self.candidateInstances count] == 0) {
        @throw [NSException exceptionWithName:@"AlchemicDependencyNotFound"
                                       reason:[NSString stringWithFormat:@"Unable to resolve dependency: %s::%s", class_getName(_instance.objectClass), ivar_getName(_variable)]
                                     userInfo:nil];
    }

}

-(NSString *) description {
    
    NSMutableArray *protocols = [[NSMutableArray alloc] initWithCapacity:[self.variableProtocols count]];
    [self.variableProtocols enumerateObjectsUsingBlock:^(Protocol *protocol, NSUInteger idx, BOOL *stop) {
        protocols[idx] = NSStringFromProtocol(protocol);
    }];

    const char *type = self.variableClass == nil ? "id" : class_getName(self.variableClass);
    return [NSString stringWithFormat:@"Variable %s::%s (%s<%@>)", class_getName(_instance.objectClass), ivar_getName(self.variable), type, [protocols componentsJoinedByString:@", "]];
    
}

@end
