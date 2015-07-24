//
//  alchemic
//
//  Created by Derek Clarkson on 17/04/2015.
//  Copyright (c) 2015 Derek Clarkson. All rights reserved.
//

@import ObjectiveC;

#import <StoryTeller/StoryTeller.h>

#import "ALCRuntime.h"
#import "ALCValueSource.h"
#import "ALCModelValueSource.h"
#import "ALCDependency.h"
#import "ALCBuilder.h"
#import "ALCAlchemic.h"
#import "ALCDependencyPostProcessor.h"
#import "ALCContext.h"

NS_ASSUME_NONNULL_BEGIN

@implementation ALCDependency {
    NSSet<id<ALCBuilder>> *_candidateBuilders;
    id<ALCValueSource> _valueSource;

}

-(nonnull instancetype) initWithValueClass:(Class _Nonnull) valueClass
                               valueSource:(nonnull id<ALCValueSource>)valueSource {
    self = [super init];
    if (self) {
        _valueClass = valueClass;
        _valueSource = valueSource;
    }
    return self;
}

-(void) resolveWithPostProcessors:(NSSet<id<ALCDependencyPostProcessor>> *) postProcessors {
    [_valueSource resolveWithPostProcessors:postProcessors];
}

-(id) value {
    return [_valueSource valueForType:self.valueClass];
}

-(NSString *) description {
    return [NSString stringWithFormat:@"%s using: %@", class_getName(_valueClass), _valueSource];
}

@end

NS_ASSUME_NONNULL_END
