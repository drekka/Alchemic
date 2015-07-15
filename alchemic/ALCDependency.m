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
#import <Alchemic/Alchemic.h>
#import "ALCValueResolver.h"

NS_ASSUME_NONNULL_BEGIN

@implementation ALCDependency {
    __weak ALCContext __nonnull *_context;
    NSSet<id<ALCBuilder>> __nonnull *_candidateBuilders;
    id<ALCValueSource> _valueSource;

}

-(nonnull instancetype) initWithContext:(__weak ALCContext __nonnull *) context
                             valueClass:(Class __nonnull) valueClass
                             valueSource:(nonnull id<ALCValueSource>)valueSource {
    self = [super init];
    if (self) {
        ALCContext *strongContext = context;
        _context = strongContext;
        _valueClass = valueClass;
        _valueSource = valueSource;
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
    return [NSString stringWithFormat:@"%s using: %@", class_getName(_valueClass), _valueSource];
}

@end

NS_ASSUME_NONNULL_END
