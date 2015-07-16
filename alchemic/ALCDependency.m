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
#import "ALCContext+Internal.h"
#import "ALCValueSource.h"
#import "ALCModelValueSource.h"
#import "ALCValueResolver.h"

NS_ASSUME_NONNULL_BEGIN

@implementation ALCDependency {
    NSSet<id<ALCBuilder>> __nonnull *_candidateBuilders;
    id<ALCValueSource> _valueSource;

}

-(nonnull instancetype) initWithValueClass:(Class __nonnull) valueClass
                               valueSource:(nonnull id<ALCValueSource>)valueSource {
    self = [super init];
    if (self) {
        _valueClass = valueClass;
        _valueSource = valueSource;
    }
    return self;
}

-(void) resolveWithPostProcessors:(NSSet<id<ALCDependencyPostProcessor>> __nonnull *) postProcessors {
    [_valueSource resolveWithPostProcessors:postProcessors];
}

-(id) value {
    return [[ALCAlchemic mainContext].valueResolver resolveValueForDependency:self fromValues:_valueSource.values];
}

-(NSString *) description {
    return [NSString stringWithFormat:@"%s using: %@", class_getName(_valueClass), _valueSource];
}

@end

NS_ASSUME_NONNULL_END
