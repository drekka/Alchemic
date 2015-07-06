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
        if ([_candidateBuilders count] == 0) {
            @throw [NSException exceptionWithName:@"AlchemicMissingQualifiers"
                                           reason:[NSString stringWithFormat:@"No qualifiers passed"]
                                         userInfo:nil];
        }
    }
    return self;
}

-(void) resolve {
    STLog(_valueClass, @"Resolving %@", self);
    ALCContext *strongContext = _context;
    [strongContext executeOnBuildersWithQualifiers:_qualifiers
                           processingBuildersBlock:^(NSSet<id<ALCBuilder>> * __nonnull builders) {
                               self->_candidateBuilders = [strongContext postProcessCandidateBuilders:builders];
                           }];
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
