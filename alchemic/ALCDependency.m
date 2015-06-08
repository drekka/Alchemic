//
//  alchemic
//
//  Created by Derek Clarkson on 17/04/2015.
//  Copyright (c) 2015 Derek Clarkson. All rights reserved.
//

@import ObjectiveC;

#import "ALCDependency.h"
#import "ALCLogger.h"
#import "ALCMatcher.h"
#import "ALCClassBuilder.h"
#import "ALCDependencyPostProcessor.h"
#import "ALCType.h"
#import "ALCClassMatcher.h"
#import "ALCProtocolMatcher.h"
#import "ALCValueResolverManager.h"

@implementation ALCDependency {
    __weak ALCContext *_context;
    NSSet *_dependencyMatchers;
    NSSet *_candidateBuilders;
}

-(instancetype) initWithContext:(__weak ALCContext *) context
                      valueType:(ALCType *) valueType
                       matchers:(NSSet *) dependencyMatchers {
    
    // If we do not have any matcher passed, derive some from the variables details.
    NSSet *matchers = dependencyMatchers;
    if (matchers == nil) {
        
        matchers = [[NSMutableSet alloc] init];
        
        if (valueType.typeClass != nil) {
            id<ALCMatcher> matcher = [ALCClassMatcher matcherWithClass:valueType.typeClass];
            [(NSMutableSet *)matchers addObject:matcher];
        }
        
        [valueType.typeProtocols enumerateObjectsUsingBlock:^(Protocol *protocol, BOOL *stop) {
            id<ALCMatcher> matcher = [ALCProtocolMatcher matcherWithProtocol:protocol];
            [(NSMutableSet *)matchers addObject:matcher];
        }];
        
    }
    
    self = [super init];
    if (self) {
        [matchers enumerateObjectsUsingBlock:^(id<ALCMatcher> matcher, BOOL *stop) {
            logRegistration(@"      %@", matcher);
        }];
        _context = context;
        _valueType = valueType;
        _dependencyMatchers = matchers;
    }
    return self;
}

-(void) resolve {

    logDependencyResolving(@"   resolving %@", self);
    ALCContext *strongContext = _context;
    _candidateBuilders = [strongContext.model buildersWithMatchers:_dependencyMatchers];
    
    for (id<ALCDependencyPostProcessor> postProcessor in strongContext.dependencyPostProcessors) {
        _candidateBuilders = [postProcessor process:_candidateBuilders];
        if ([_candidateBuilders count] == 0) {
            break;
        }
    }
    
    logDependencyResolving(@"   found %lu candidates", [_candidateBuilders count]);
    
    // If there are no candidates left then error.
    if ([_candidateBuilders count] == 0) {
        @throw [NSException exceptionWithName:@"AlchemicDependencyNotFound"
                                       reason:[NSString stringWithFormat:@"Unable to resolve dependency: %s", class_getName(_valueType.typeClass)]
                                     userInfo:nil];
    }
    
}

-(id) value {
    ALCContext *strongContext = _context;
    return [strongContext.valueResolverManager resolveValueForDependency:self candidates:_candidateBuilders];
}

-(NSString *) description {
    
    NSMutableArray *protocols = [[NSMutableArray alloc] initWithCapacity:[_valueType.typeProtocols count]];
    [_valueType.typeProtocols enumerateObjectsUsingBlock:^(Protocol *protocol, BOOL *stop) {
        [protocols addObject:NSStringFromProtocol(protocol)];
    }];
    
    const char *type = _valueType.typeClass == nil ? "id" : class_getName(_valueType.typeClass);
    return [NSString stringWithFormat:@"Dependency %s<%@>", type, [protocols componentsJoinedByString:@", "]];
    
}

@end
