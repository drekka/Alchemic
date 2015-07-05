//
//  alchemic
//
//  Created by Derek Clarkson on 17/04/2015.
//  Copyright (c) 2015 Derek Clarkson. All rights reserved.
//

@import ObjectiveC;

#import <Alchemic/Alchemic.h>
#import <StoryTeller/StoryTeller.h>
#import "ALCRuntime.h"

@implementation ALCDependency {
    __weak ALCContext __nonnull *_context;
    NSSet<ALCQualifier *> __nonnull *_qualifiers;
    NSSet<id<ALCBuilder>> __nonnull *_candidateBuilders;
}

-(nonnull instancetype) initWithContext:(__weak ALCContext __nonnull *) context
                             valueClass:(Class __nonnull) valueClass
                             qualifiers:(NSSet<ALCQualifier *> __nonnull *) qualifiers {
    self = [super init];
    if (self) {
        _context = context;
        _valueClass = valueClass;
        _qualifiers = qualifiers == nil || [qualifiers count] == 0 ? [ALCRuntime qualifiersForClass:valueClass] : qualifiers;
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
    NSMutableArray<NSString *> *qualifierDescs = [[NSMutableArray alloc] init];
    [_qualifiers enumerateObjectsUsingBlock:^(ALCQualifier *qualifier, BOOL *stop) {
        [qualifierDescs addObject:[qualifier description]];
    }];
    return [NSString stringWithFormat:@"%s using %@", class_getName(_valueClass), [qualifierDescs componentsJoinedByString:@", "]];
}

@end
