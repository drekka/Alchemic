//
//  alchemic
//
//  Created by Derek Clarkson on 17/04/2015.
//  Copyright (c) 2015 Derek Clarkson. All rights reserved.
//

#import "ALCDependency.h"
#import "ALCLogger.h"
@import ObjectiveC;
#import "ALCMatcher.h"
#import "ALCClassBuilder.h"
#import "ALCDependencyPostProcessor.h"
#import "ALCType.h"
#import "ALCClassMatcher.h"
#import "ALCProtocolMatcher.h"

@implementation ALCDependency {
    __weak ALCContext *_context;
    id<ALCValueProcessor> _valueProcessor;
    NSSet *_dependencyMatchers;
    NSSet *_candidateBuilders;
    id _value;
}

@synthesize valueType = _valueType;
@synthesize value = _value;

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
        _valueProcessor = [context.valueProcessorFactory valueProcessorForDependency:self];
    }
    return self;
}

-(void) resolve {
    
    _candidateBuilders = [_context.model buildersWithMatchers:_dependencyMatchers];
    
    for (id<ALCDependencyPostProcessor> postProcessor in _context.dependencyPostProcessors) {
        _candidateBuilders = [postProcessor process:_candidateBuilders];
        if ([_candidateBuilders count] == 0) {
            break;
        }
    }
    
    logDependencyResolving(@"Found %lu candidates", [_candidateBuilders count]);
    
    // If there are no candidates left then error.
    if ([_candidateBuilders count] == 0) {
        @throw [NSException exceptionWithName:@"AlchemicDependencyNotFound"
                                       reason:[NSString stringWithFormat:@"Unable to resolve dependency: %s", class_getName(_valueType.typeClass)]
                                     userInfo:nil];
    }
    
    // Validate with the value processor.
    [_valueProcessor validateCandidates:_candidateBuilders];
    
}

-(id) value {
    return [_valueProcessor resolveCandidateValues:_candidateBuilders];
}

-(NSString *) description {
    
    NSMutableArray *protocols = [[NSMutableArray alloc] initWithCapacity:[self.valueType.typeProtocols count]];
    [self.valueType.typeProtocols enumerateObjectsUsingBlock:^(Protocol *protocol, BOOL *stop) {
        [protocols addObject:NSStringFromProtocol(protocol)];
    }];
    
    const char *type = self.valueType.typeClass == nil ? "id" : class_getName(self.valueType.typeClass);
    return [NSString stringWithFormat:@"Dependency %s<%@>", type, [protocols componentsJoinedByString:@", "]];
    
}

@end
