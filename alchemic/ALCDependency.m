//
//  alchemic
//
//  Created by Derek Clarkson on 17/04/2015.
//  Copyright (c) 2015 Derek Clarkson. All rights reserved.
//

@import ObjectiveC;

#import <Alchemic/ALCDependency.h>
#import <StoryTeller/StoryTeller.h>
#import <Alchemic/ALCContext.h>
#import <Alchemic/ALCClassMatcher.h>
#import <Alchemic/ALCProtocolMatcher.h>
#import "NSDictionary+ALCModel.h"
#import "ALCRuntime.h"

@implementation ALCDependency {
    __weak ALCContext __nonnull *_context;
    NSSet<id<ALCMatcher>> __nonnull *_dependencyMatchers;
    NSSet<id<ALCBuilder>> __nonnull *_candidateBuilders;
}

-(nonnull instancetype) initWithContext:(__weak ALCContext __nonnull *) context
                             valueClass:(Class __nonnull) valueClass
                               matchers:(NSSet<id<ALCMatcher>> __nullable *) dependencyMatchers {
    self = [super init];
    if (self) {
        _context = context;
        _valueClass = valueClass;
        _dependencyMatchers = dependencyMatchers == nil || [dependencyMatchers count] == 0 ? [ALCRuntime matchersForClass:valueClass] : dependencyMatchers;
    }
    return self;
}

-(void) resolve {

    STLog(_valueClass, @"Resolving %@", self);
    ALCContext *strongContext = _context;
    _candidateBuilders = [strongContext.model buildersWithMatchers:_dependencyMatchers];
    
    for (id<ALCDependencyPostProcessor> postProcessor in strongContext.dependencyPostProcessors) {
        _candidateBuilders = [postProcessor process:_candidateBuilders];
        if ([_candidateBuilders count] == 0) {
            break;
        }
    }
    
    STLog(_valueClass, @"Found %lu candidates", [_candidateBuilders count]);
    
    // If there are no candidates left then error.
    if ([_candidateBuilders count] == 0) {
        @throw [NSException exceptionWithName:@"AlchemicDependencyNotFound"
                                       reason:[NSString stringWithFormat:@"Unable to resolve dependency: %s", class_getName(_valueClass)]
                                     userInfo:nil];
    }
    
}

-(id) value {
    ALCContext *strongContext = _context;
    return [strongContext.valueResolverManager resolveValueForDependency:self candidates:_candidateBuilders];
}

-(NSString *) description {
    NSMutableArray<NSString *> *matcherDescs = [[NSMutableArray alloc] init];
    [_dependencyMatchers enumerateObjectsUsingBlock:^(id<ALCMatcher> matcher, BOOL *stop) {
        [matcherDescs addObject:[matcher description]];
    }];
    return [NSString stringWithFormat:@"%s using %@", class_getName(_valueClass), [matcherDescs componentsJoinedByString:@", "]];
}

@end
