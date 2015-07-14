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
#import "ALCValueSource.h"
#import "ALCModelValueSource.h"

@implementation ALCDependency {
    __weak ALCContext __nonnull *_context;
    NSSet<ALCQualifier *> __nonnull *_qualifiers;
    NSSet<id<ALCBuilder>> __nonnull *_candidateBuilders;
    id<ALCValueSource> _valueSource;

}

-(nonnull instancetype) initWithContext:(__weak ALCContext __nonnull *) context
                             valueClass:(Class __nonnull) valueClass
                             qualifiers:(NSSet<ALCQualifier *> __nonnull *) qualifiers {
    self = [super init];
    if (self) {
        ALCContext *strongContext = context;
        _context = strongContext;
        _valueClass = valueClass;
        _qualifiers = qualifiers;
        _valueSource = [[ALCModelValueSource alloc] initWithContext:strongContext
                                                         qualifiers:qualifiers];
    }
    return self;
}

-(void) resolveWithPostProcessors:(NSSet<id<ALCDependencyPostProcessor>> __nonnull *) postProcessors {
    [_valueSource resolveWithPostProcessors:postProcessors];
}

-(id) value {
    return [_context.valueResolver resolveValueForDependency:self fromValues:_valueSource.values];
}

-(NSString *) description {
    NSMutableArray<NSString *> *qualifierDescs = [[NSMutableArray alloc] init];
    [_qualifiers enumerateObjectsUsingBlock:^(ALCQualifier *qualifier, BOOL *stop) {
        [qualifierDescs addObject:[qualifier description]];
    }];
    return [NSString stringWithFormat:@"%s using: %@", class_getName(_valueClass), [qualifierDescs componentsJoinedByString:@", "]];
}

@end
