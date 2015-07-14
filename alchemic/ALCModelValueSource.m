//
//  ALCModelValueSource.m
//  Alchemic
//
//  Created by Derek Clarkson on 14/07/2015.
//  Copyright © 2015 Derek Clarkson. All rights reserved.
//

#import "ALCModelValueSource.h"
#import <StoryTeller/StoryTeller.h>
#import "ALCContext+Internal.h"
#import <Alchemic/ALCBuilder.h>

NS_ASSUME_NONNULL_BEGIN

/**
 Sources values from the model.
 */
@implementation ALCModelValueSource {
    __weak ALCContext *_context;
    NSSet<ALCQualifier *> *_qualifiers;
    NSSet<id<ALCBuilder>> *_candidateBuilders;
}

@synthesize values = _values;

-(instancetype)initWithContext:(ALCContext * __weak)context
                            qualifiers:(nonnull NSSet<ALCQualifier *> *)qualifiers {
    self = [super init];
    if (self) {
        _qualifiers = qualifiers;
        _context = context;
        if ([_qualifiers count] == 0) {
            @throw [NSException exceptionWithName:@"AlchemicMissingQualifiers"
                                           reason:[NSString stringWithFormat:@"No qualifiers passed"]
                                         userInfo:nil];
        }
    }
    return self;
}

-(NSSet<id> *) values {
    NSMutableSet<id> *results = [[NSMutableSet alloc] init];
    [_candidateBuilders enumerateObjectsUsingBlock:^(id<ALCBuilder> builder, BOOL * stop) {
        [results addObject:builder.value];
    }];
    return results;
}

-(void) resolveWithPostProcessors:(NSSet<id<ALCDependencyPostProcessor>> *) postProcessors {

    STLog(self, @"Resolving %@", self);
    STStartScope(self);
    ALCContext *strongContext = _context;
    [strongContext executeOnBuildersWithQualifiers:_qualifiers
                           processingBuildersBlock:^(NSSet<id<ALCBuilder>> * builders) {

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
        [_qualifiers enumerateObjectsUsingBlock:^(ALCQualifier * qualifier, BOOL * stop) {
            [qualifierDescs addObject:[qualifier description]];
        }];

        @throw [NSException exceptionWithName:@"AlchemicNoCandidateBuildersFound"
                                       reason:[NSString stringWithFormat:@"Unable to resolve value using %@ - no candidate builders found.", [qualifierDescs componentsJoinedByString:@", "]]
                                     userInfo:nil];
    }
}

@end

NS_ASSUME_NONNULL_END