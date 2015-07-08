//
//  alchemic
//
//  Created by Derek Clarkson on 17/04/2015.
//  Copyright (c) 2015 Derek Clarkson. All rights reserved.
//

@import ObjectiveC;

#import <StoryTeller/StoryTeller.h>
#import "ALCRuntime.h"
#import "ALCContext+Internal.h"

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
        _qualifiers = qualifiers;
        if ([_qualifiers count] == 0) {
            @throw [NSException exceptionWithName:@"AlchemicMissingQualifiers"
                                           reason:[NSString stringWithFormat:@"No qualifiers passed"]
                                         userInfo:nil];
        }
    }
    return self;
}

-(void) resolveWithPostProcessors:(NSSet<id<ALCDependencyPostProcessor>> __nonnull *) postProcessors {

    STLog(_valueClass, @"Resolving %@", self);
    ALCContext *strongContext = _context;
    [strongContext executeOnBuildersWithQualifiers:_qualifiers
                           processingBuildersBlock:^(NSSet<id<ALCBuilder>> * __nonnull builders) {

                               NSSet<id<ALCBuilder>> *finalBuilders = builders;
                               for (id<ALCDependencyPostProcessor> postProcessor in postProcessors) {
                                   finalBuilders = [postProcessor process:finalBuilders];
                                   if ([finalBuilders count] == 0) {
                                       break;
                                   }
                               }

                               STLog(ALCHEMIC_LOG, @"Found %lu candidates", [finalBuilders count]);
                               self->_candidateBuilders = finalBuilders;
                           }];

    // If there are no candidates left then error.
    if ([_candidateBuilders count] == 0) {

        NSMutableArray<NSString *> *qualifierDescs = [[NSMutableArray alloc] initWithCapacity:[_qualifiers count]];
        [_qualifiers enumerateObjectsUsingBlock:^(ALCQualifier * __nonnull qualifier, BOOL * __nonnull stop) {
            [qualifierDescs addObject:[qualifier description]];
        }];

        @throw [NSException exceptionWithName:@"AlchemicNoCandidateBuildersFound"
                                       reason:[NSString stringWithFormat:@"Unable to resolve dependency %@ using %@ - no builders found.", NSStringFromClass(_valueClass), [qualifierDescs componentsJoinedByString:@", "]]
                                     userInfo:nil];
    }
}

-(id) value {
    return [_context resolveValueForDependency:self candidates:_candidateBuilders];
}

-(NSString *) description {
    NSMutableArray<NSString *> *qualifierDescs = [[NSMutableArray alloc] init];
    [_qualifiers enumerateObjectsUsingBlock:^(ALCQualifier *qualifier, BOOL *stop) {
        [qualifierDescs addObject:[qualifier description]];
    }];
    return [NSString stringWithFormat:@"%s using %@", class_getName(_valueClass), [qualifierDescs componentsJoinedByString:@", "]];
}

@end
