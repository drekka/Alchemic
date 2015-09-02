//
//  alchemic
//
//  Created by Derek Clarkson on 17/04/2015.
//  Copyright (c) 2015 Derek Clarkson. All rights reserved.
//

@import ObjectiveC;

#import <StoryTeller/StoryTeller.h>

#import "ALCValueSource.h"
#import "ALCDependency.h"
#import "ALCDependencyPostProcessor.h"
#import "ALCRuntime.h"

NS_ASSUME_NONNULL_BEGIN

@implementation ALCDependency

-(instancetype) init {
    return nil;
}

-(instancetype) initWithValueSource:(id<ALCValueSource>) valueSource {
    self = [super init];
    if (self) {
        _valueSource = valueSource;
    }
    return self;
}

-(void) resolveWithPostProcessors:(NSSet<id<ALCDependencyPostProcessor>> *) postProcessors
                  dependencyStack:(NSMutableArray<id<ALCResolvable>> *)dependencyStack {
    [_valueSource resolveWithPostProcessors:postProcessors dependencyStack:dependencyStack];
}

-(id) value {
    return _valueSource.value;
}

-(Class)valueClass {
    return _valueSource.valueClass;
}

-(NSString *) description {
    return [NSString stringWithFormat:@"%@ -> %@", [ALCRuntime aClassDescription:_valueSource.valueClass], _valueSource];
}

@end

NS_ASSUME_NONNULL_END
